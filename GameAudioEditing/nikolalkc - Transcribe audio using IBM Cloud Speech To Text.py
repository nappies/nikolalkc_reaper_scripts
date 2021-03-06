import os
import json
from os.path import join, dirname
from watson_developer_cloud import SpeechToTextV1 as SpeechToText
def transcribe_audio(path_to_audio_file):
    # enter your info here
    username = ""
    password = ""
    speech_to_text = SpeechToText(username=username,
                                  password=password)

    with open(path_to_audio_file, 'rb') as audio_file:
        return speech_to_text.recognize(audio_file,
            content_type='audio/wav')

def main():
	RPR_ShowConsoleMsg("Transcribing audio....\n")

	item = RPR_GetSelectedMediaItem( 0, 0)
	take =  RPR_GetMediaItemTake( item, 0)
	source =  RPR_GetMediaItemTake_Source( take )
	(filepath, filenamebuf, filenamebuf_sz)  = RPR_GetMediaSourceFileName(source, "", 256 )

	result = transcribe_audio(filenamebuf)
	
	text = result['results'][0]['alternatives'][0]['transcript']
	RPR_ShowConsoleMsg(text)
	RPR_ShowConsoleMsg("\n")

main()

