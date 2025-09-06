#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Instagram Publishing – ยิงตอนถึงเวลา (ไม่ schedule ในแพลตฟอร์ม)"""
import os, time, json, requests

def ig_publish_image(ig_business_id: str, access_token: str, image_url: str, caption: str):
    # โฟลว์มาตรฐาน: สร้าง media → publish
    create_url = f"https://graph.facebook.com/v19.0/{ig_business_id}/media"
    publish_url = f"https://graph.facebook.com/v19.0/{ig_business_id}/media_publish"
    # ใช้งานไฟล์โลคอลให้เปิดเป็น public URL ก่อน หรืออัปโหลดไป object storage แล้วใช้ URL
    r1 = requests.post(create_url, data={"image_url": image_url, "caption": caption, "access_token": access_token}, timeout=60)
    media_id = r1.json().get("id")
    r2 = requests.post(publish_url, data={"creation_id": media_id, "access_token": access_token}, timeout=60)
    return r1.status_code, r1.text, r2.status_code, r2.text
