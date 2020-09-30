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
function toggleInputSource()
	-- print(hs.keycodes.currentSourceID())
	if (lastToggleInputSource == inputKorean) then
		hs.keycodes.currentSourceID(inputJapanese)
		lastToggleInputSource = inputJapanese
	else
		hs.keycodes.currentSourceID(inputKorean)
		lastToggleInputSource = inputKorean
	end
end

---------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------

-- initialization
hs.keycodes.currentSourceID(inputKorean)
local lastToggleInputSource = inputKorean
local lastInputSource = inputKorean

-- 키바인딩
hs.hotkey.bind({'control'}, 33, escapeForVIM)
hs.hotkey.bind({'option'}, 'space', openIterm)
hs.hotkey.bind({'control'}, 'space', toggleInputSource)

-- 기타 이벤트
local start_time = os.time()
local consecutive_call_cnt = 0
hs.keycodes.inputSourceChanged(function ()
	-- focus 감지 로
	-- inupt 에 포커싱 할 경우 콜백이 연속 3~4번 호출된다는 규칙을 보고 트릭 사용
	-- focus, prompt 감지 api는 없는걸까...
	if (os.difftime(os.time(), start_time) > 1) then -- 이전포커싱과 2초차이 나는경우 새로운 창을 클릭했다 가
		consecutive_call_cnt = 0
		start_time = os.time()
	end
	consecutive_call_cnt = consecutive_call_cnt + 1
	print(consecutive_call_cnt)
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
end)

-- 예제공부
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
	hs.alert.show(hs.keycodes.currentSourceID())
end)