---------------------------------------------------------------------------------
-- settings
---------------------------------------------------------------------------------

-- 상수
local inputEnglish = 'com.apple.keylayout.ABC'
local inputKorean = 'com.apple.inputmethod.Korean.390Sebulshik'
local inputJapanese = 'com.apple.inputmethod.Kotoeri.Japanese'
local inputLabels = {
	[inputEnglish] = 'English',
	[inputKorean] = '한국어',
	[inputJapanese] = '日本語'
}

-- alert 스타일 세팅
hs.alert.defaultStyle.textStyle = {paragraphStyle = {alignment = "center"}}

---------------------------------------------------------------------------------
-- 함수 정의부
---------------------------------------------------------------------------------

function escapeForVIM()
	local inputSource = hs.keycodes.currentSourceID()
	if not (inputSource == inputEnglish) then
		hs.eventtap.keyStroke({}, 'right')
		hs.keycodes.currentSourceID(inputEnglish)
	end
	hs.eventtap.keyStroke({}, 'escape')
end

function openIterm()
	hs.application.open('/Applications/iTerm.app')
end

-- 한글에서 capslock으로 영어로 바꿨을 때도 토글명령시 바로 일본어로 토글해주는 함수
hs.keycodes.currentSourceID(inputKorean)
local lastToggleInputSource = inputKorean
local lastInputSource = inputKorean
function toggleInputSource()
	if (lastToggleInputSource == inputKorean) then
		hs.keycodes.currentSourceID(inputJapanese)
		lastToggleInputSource = inputJapanese
	else
		hs.keycodes.currentSourceID(inputKorean)
		lastToggleInputSource = inputKorean
		-- 이 구문에서 윗줄 코드를 찾는데 변수정의돼있지 않으면 새로운 전역을 생성하게 된다.
	end
end

-- 인풋소스 체인지 이벤트 (input 박스 셀릭트 탐지 로직 적용)
-- 지역변수 선언 지저분함. 나중에 수정하자.
local start_time = os.time()
local consecutive_call_cnt = 0
function handleInputSourceChange()
	-- focus 감지 로
	-- inupt 에 포커싱 할 경우 콜백이 연속 3~4번 호출된다는 규칙을 보고 트릭 사용
	-- focus, prompt 감지 api는 없는걸까...
	if (os.difftime(os.time(), start_time) > 1) then -- 이전포커싱과 2초차이 나는경우 새로운 창을 클릭했다 가
		consecutive_call_cnt = 0
		start_time = os.time()
	end
	consecutive_call_cnt = consecutive_call_cnt + 1
	-- print(consecutive_call_cnt)
	if (consecutive_call_cnt == 3 or consecutive_call_cnt == 4) then
		hs.alert.closeAll()
		hs.alert.show(inputLabels[hs.keycodes.currentSourceID()], 1)
	end

	-- 키보드 언어 변경 감지
	local currentInputSource = hs.keycodes.currentSourceID()
	if not (lastInputSource == currentInputSource) then
		lastInputSource = currentInputSource
		hs.alert.closeAll()
		hs.alert.show(inputLabels[hs.keycodes.currentSourceID()], 1)
	end
end

-- 클립보드 가공
local function cleanPasteboard()
	local pb = hs.pasteboard.contentTypes()
	local contains = hs.fnutils.contains
	if contains(pb, 'com.apple.webarchive') and contains(pb, 'public.rtf') then
		hs.pasteboard.setContents(hs.pasteboard.getContents())
	end 
end

---------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------

-- initialization
hs.loadSpoon('ReloadConfiguration')
local messagesWindowFilter = hs.window.filter.new(false):setAppFilter('Messages')
messagesWindowFilter:subscribe(hs.window.filter.windowFocused, cleanPasteboard)
-- hs.application.enableSpotlightForNameSearches(true)

-- 키바인딩 이벤트
hs.hotkey.bind({'control'}, 33, escapeForVIM)
hs.hotkey.bind({'option'}, 'space', openIterm)
hs.hotkey.bind({'control'}, 'space', toggleInputSource)
spoon.ReloadConfiguration:bindHotkeys({
	reloadConfiguration = {{"cmd", "alt", "ctrl"}, "R"}
})

-- 기타 이벤트
hs.keycodes.inputSourceChanged(handleInputSourceChange)

-- 최종 Config File 와칭 설정
spoon.ReloadConfiguration:start()
hs.alert.show('Config loaded') 

-- 예제공부 (Getting Started To Hammerspoon)
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'Left', function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y
	f.w = max.w / 2
	f.h = max.h
	win:setFrame(f)
	-- hs.alert.show('화면조정')
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'Right', function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w / 2)
	f.y = max.y
	f.w = max.w / 2
	f.h = max.h
	win:setFrame(f)
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'Up', function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y
	f.w = max.w
	f.h = max.h / 2
	win:setFrame(f)
end)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'Down', function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y + (max.h / 2)
	f.w = max.w
	f.h = max.h / 2
	win:setFrame(f)
end)

-- -- 화면 미리세팅
-- local laptopScreen = "Color LCD"
-- local windowLayout = {
--     {"Safari",  nil,          laptopScreen, hs.layout.left50,    nil, nil},
--     {"Mail",    nil,          laptopScreen, hs.layout.right50,   nil, nil},
--     {"iTunes",  "iTunes",     laptopScreen, hs.layout.maximized, nil, nil},
--     {"iTunes",  "MiniPlayer", laptopScreen, nil, nil, hs.geometry.rect(0, -48, 400, 48)},
-- }
-- hs.layout.apply(windowLayout)

-- -- GUI 메뉴 자동화
-- function cycle_safari_agents()
--     hs.application.launchOrFocus("Safari")
--     local safari = hs.appfinder.appFromName("Safari")

--     local str_default = {"Develop", "User Agent", "Default (Automatically Chosen)"}
--     local str_ie10 = {"Develop", "User Agent", "Internet Explorer 10.0"}
--     local str_chrome = {"Develop", "User Agent", "Google Chrome — Windows"}

--     local default = safari:findMenuItem(str_default)
--     local ie10 = safari:findMenuItem(str_ie10)
--     local chrome = safari:findMenuItem(str_chrome)
--     print(default, ie10, chrome)
--     if (default and default["ticked"]) then
--         safari:selectMenuItem(str_ie10)
--         hs.alert.show("IE10")
--     end
--     if (ie10 and ie10["ticked"]) then
--         safari:selectMenuItem(str_chrome)
--         hs.alert.show("Chrome")
--     end
--     if (chrome and chrome["ticked"]) then
--         safari:selectMenuItem(str_default)
--         hs.alert.show("Safari")
--     end
-- end
-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, '7', cycle_safari_agents)