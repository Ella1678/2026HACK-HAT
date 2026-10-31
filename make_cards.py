from PIL import Image, ImageDraw, ImageFilter, ImageFont
import random

W,H=1280,720
FONT='/System/Library/Fonts/STHeiti Light.ttc'

def font(sz):
    return ImageFont.truetype(FONT, sz)

def skyline(draw, base_y, ground_color=(8,10,13), top_color=(5,6,8)):
    random.seed(7)
    y=base_y
    x=0
    while x < W:
        bw=random.randint(18,72)
        bh=random.randint(80,260)
        draw.rectangle([x,y-bh,x+bw,y], fill=ground_color)
        # broken spire
        if random.random()<0.35:
            sx=x+bw/2
            draw.polygon([(sx-6,y-bh-28),(sx+6,y-bh-28),(sx,y-bh)], fill=ground_color)
        if random.random()<0.12:
            draw.rectangle([x+4,y-bh-14,x+bw-4,y-bh], fill=ground_color)
        x+=bw+random.randint(8,30)
    draw.rectangle([0,y,W,H], fill=top_color)

def opening():
    img=Image.new('RGB',(W,H),(10,14,18))
    d=ImageDraw.Draw(img)
    # pale cold sky glow
    glow=Image.new('RGB',(W,H),(0,0,0))
    gd=ImageDraw.Draw(glow)
    gd.ellipse([W*0.62-170,H*0.18-170,W*0.62+170,H*0.18+170],fill=(150,160,165))
    glow=glow.filter(ImageFilter.GaussianBlur(120))
    img=Image.blend(img,glow,0.35)
    d=ImageDraw.Draw(img)
    skyline(d,H*0.72)
    # ground fog
    fog=Image.new('RGB',(W,H),(0,0,0))
    fd=ImageDraw.Draw(fog)
    fd.rectangle([0,H*0.66,W,H],fill=(35,42,48))
    fog=fog.filter(ImageFilter.GaussianBlur(40))
    img=Image.blend(img,fog,0.55)
    d=ImageDraw.Draw(img)
    d.text((W/2,H*0.30),'公元 2157 年',font=font(60),fill=(225,232,235),anchor='mm')
    d.text((W/2,H*0.42),'能源枯竭，文明濒临灭绝',font=font(38),fill=(168,182,188),anchor='mm')
    d.text((W/2,H*0.80),'火种计划 · 地心航线',font=font(34),fill=(190,214,220),anchor='mm')
    img.save('/Users/ziki/Documents/Codex/2026-09-05/s-f/work/trailer/opening.png')

def ending():
    img=Image.new('RGB',(W,H),(2,2,3))
    d=ImageDraw.Draw(img)
    # dim red/cyan line near center, iron gap light
    d.line([W*0.30,H*0.56,W*0.70,H*0.56],fill=(90,25,30),width=2)
    d.text((W/2,H*0.34),'信号丢失',font=font(70),fill=(235,235,238),anchor='mm')
    d.text((W/2,H*0.52),'火种-7，任务结束',font=font(34),fill=(170,180,185),anchor='mm')
    d.text((W/2,H*0.68),'人类的监视器信号丢失',font=font(26),fill=(120,135,140),anchor='mm')
    d.text((W/2,H*0.82),'它最后，是否推开了那扇门？',font=font(26),fill=(95,110,116),anchor='mm')
    img.save('/Users/ziki/Documents/Codex/2026-09-05/s-f/work/trailer/ending.png')

import os
os.makedirs('/Users/ziki/Documents/Codex/2026-09-05/s-f/work/trailer',exist_ok=True)
opening(); ending()
print('ok')
