import azure.cognitiveservices.speech as speechsdk
from datetime import datetime

# <<< ใส่ค่าให้ถูกต้อง >>>
SPEECH_KEY = "43828e9db0d0b7ada04afbcfbead43f2"
SPEECH_REGION = "centralus"  # เช่น eastasia, southeastasia

# เลือกเสียงไทย: "th-TH-NiwatNeural" (ชาย) หรือ "th-TH-PremwadeeNeural" (หญิง)
VOICE = "th-TH-NiwatNeural"
OUTFILE = f"morning_knowing_mind_{datetime.now().strftime('%Y%m%d_%H%M%S')}.mp3"

# ข้อความนำภาวนา (ย่อ/ยาวได้ตามต้องการ)
script_text = """
การฝึกเข้าถึงตัวรู้ ยามเช้ามืดหลังตื่น

เชิญนั่งในท่าที่สบาย หลังตรงพองาม ผ่อนคลาย
หายใจเข้า รู้ … หายใจออก รู้ … ไม่ต้องบังคับ
ถ้าเผลอคิด ก็แค่รู้ว่าเผลอ แล้วกลับมาที่การรู้ตัว
วันนี้ตั้งเจตนาให้เต็มไปด้วยสติ เมตตา และปัญญา
สาธุ
"""

# ใช้ SSML เพื่อปรับน้ำเสียงให้สงบ นุ่ม (ปรับ rate/pitch ได้)
ssml = f"""
<speak version="1.0" xml:lang="th-TH">
  <voice name="{VOICE}">
    <prosody rate="0%" pitch="-2st">
      {script_text}
    </prosody>
  </voice>
</speak>
"""

speech_config = speechsdk.SpeechConfig(subscription=SPEECH_KEY, region=SPEECH_REGION)
audio_config = speechsdk.audio.AudioConfig(filename=OUTFILE)
synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

result = synthesizer.speak_ssml_async(ssml).get()

if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
    print("✅ สร้างไฟล์:", OUTFILE)
else:
    print("❌ Error:", result.reason)
    if result.cancellation_details:
        print("Details:", result.cancellation_details.error_details)
