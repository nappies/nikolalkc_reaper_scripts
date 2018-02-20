import os
import json
from os.path import join, dirname
from watson_developer_cloud import SpeechToTextV1 as SpeechToText
def transcribe_audio(path_to_audio_file):
    username = "e8196f68-67ad-42a2-a5cc-cbff3b563c2a"
    password = "BKxcdajdCfT0"
    speech_to_text = SpeechToText(username=username,
                                  password=password)

    with open(path_to_audio_file, 'rb') as audio_file:
        return speech_to_text.recognize(audio_file,
            content_type='audio/ogg')

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

