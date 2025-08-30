#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Facebook Page – Scheduled Post (ตัวอย่างโครงสร้าง)"""
import os, json, requests

def schedule_fb_image(page_access_token: str, page_id: str, image_path: str, caption: str, scheduled_unix: int):
    # NOTE: ตัวอย่าง endpoint – โปรดตรวจสอบเวอร์ชัน API และ permission ที่ใช้จริง
    url = f"https://graph.facebook.com/v19.0/{page_id}/photos"
    payload = {
        "caption": caption,
        "published": False,
        "scheduled_publish_time": scheduled_unix
    }
    files = {
        "source": open(image_path, "rb")
    }
    params = { "access_token": page_access_token }
    r = requests.post(url, data=payload, files=files, params=params, timeout=60)
    return r.status_code, r.text
