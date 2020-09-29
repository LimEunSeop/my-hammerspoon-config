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

-- initialization
hs.keycodes.currentSourceID(inputKorean)
local lastToggleInputSource = inputKorean
local lastInputSource = inputKorean

-- 키바인딩
hs.hotkey.bind({'control'}, 33, escapeForVIM)
hs.hotkey.bind({'option'}, 'space', openIterm)
hs.hotkey.bind({'control'}, 'space', toggleInputSource)

-- 기타 이벤트
hs.keycodes.inputSourceChanged(function ()
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