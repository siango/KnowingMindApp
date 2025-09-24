#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ArunRoo Publisher – โครงสคริปต์พื้นฐาน
อ่าน postmap CSV → คัดรายการที่ถึงเวลา → ยิง API แพลตฟอร์ม
(เติมโทเคนจริงจากไฟล์ .env ก่อนใช้งาน)
"""
import os, csv, time, json, datetime
from pathlib import Path

def read_postmap(path):
    rows = []
    with open(path, encoding='utf-8') as f:
        for r in csv.DictReader(f):
            rows.append(r)
    return rows

def due_rows(rows, now: datetime.datetime, window_minutes=5):
    out = []
    tz = os.getenv("TIMEZONE", "Asia/Bangkok")
    for r in rows:
        # ตีความเป็น naive แล้วเทียบเวลาท้องถิ่น (อย่างง่าย)
        dt = datetime.datetime.fromisoformat(r['datetime'])
        delta = (dt - now).total_seconds() / 60.0
        if -window_minutes <= delta <= window_minutes and r.get('status','pending') == 'pending':
            out.append(r)
    return out

if __name__ == "__main__":
    postmap = os.getenv("POSTMAP_PATH", "./outputs/postmap_2025-08.csv")
    now = datetime.datetime.now()
    rows = read_postmap(postmap)
    todo = due_rows(rows, now)
    print(f"[INFO] now={now.isoformat()} due={len(todo)}")
    # ต่อจากนี้: เรียกฟังก์ชันแต่ละแพลตฟอร์มตาม r['platform']
