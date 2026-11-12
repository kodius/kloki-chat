#!/usr/bin/env python3
"""Replace icons in assets/icons/ with their Lucide counterparts.

Kloki's web app and Kloki GO draw Lucide icons, so this app does too,
wherever Lucide has the icon.  The rest stay as Zulip drew them.

Lucide's SVGs are strokes, which an icon font can't hold,
so this takes the outlines from Lucide's own icon font instead.

Usage:
  npm pack lucide-static@1.45.0 && tar xzf lucide-static-1.45.0.tgz
  pip install fonttools
  tools/icons/import-lucide.py package/
  tools/icons/build-icon-font
"""

import json
import os
import sys

from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

# Our icon name -> Lucide's.
ICONS = {
    'arrow_left_right': 'arrow-left-right',
    'at_sign': 'at-sign',
    'attach_file': 'paperclip',
    'bot': 'bot',
    'camera': 'camera',
    'check': 'check',
    'check_check': 'check-check',
    'check_circle_checked': 'circle-check',
    'check_circle_unchecked': 'circle',
    'check_remove': 'undo-2',
    'chevron_down': 'chevron-down',
    'chevron_left': 'chevron-left',
    'chevron_right': 'chevron-right',
    'chevron_up': 'chevron-up',
    'circle_alert': 'circle-alert',
    'circle_chevron_down': 'circle-chevron-down',
    'circle_pause': 'circle-pause',
    'circle_play': 'circle-play',
    'circle_x': 'circle-x',
    'clock': 'clock',
    'contacts': 'contact',
    'copy': 'copy',
    'edit': 'square-pen',
    'external_link': 'external-link',
    'eye': 'eye',
    'eye_off': 'eye-off',
    'flag': 'flag',
    'follow': 'bell-plus',
    'format_quote': 'quote',
    'globe': 'globe',
    'hash_italic': 'hash',
    'hash_sign': 'hash',
    'help': 'circle-question-mark',
    'image': 'image',
    'inbox': 'inbox',
    'info': 'info',
    'inherit': 'bell',
    'language': 'languages',
    'link': 'link',
    'lock': 'lock',
    'mail': 'mail',
    'menu': 'menu',
    'message_checked': 'message-square-check',
    'message_feed': 'messages-square',
    'message_unread': 'message-square-dot',
    'moon': 'moon',
    'more_horizontal': 'ellipsis',
    'mute': 'bell-off',
    'person': 'user',
    'pin': 'pin',
    'pin_remove': 'pin-off',
    'plus': 'plus',
    'read_receipts': 'book-open-check',
    'remove': 'x',
    'search': 'search',
    'see_who_reacted': 'scroll-text',
    'send': 'send',
    'server': 'server',
    'settings': 'settings',
    'share': 'share-2',
    'share_ios': 'share',
    'smile': 'smile',
    'star': 'star',
    'sun': 'sun',
    'three_person': 'users-round',
    'topic': 'message-square-text',
    'topics': 'list',
    'trash': 'trash-2',
    'two_person': 'users',
    'unmute': 'bell-ring',
}

# Our icon name -> a Lucide icon to fill in: only its largest contour is kept.
FILLED_ICONS = {
    'play_filled': 'play',
    'star_filled': 'star',
}

GRID = 24


def contour_area(contour):
    points = [args[-1] for op, args in contour if args]
    return abs(sum(x0 * y1 - x1 * y0
                   for (x0, y0), (x1, y1) in zip(points, points[1:] + points[:1])))


def split_contours(ops):
    contours = []
    for op in ops:
        if op[0] == 'moveTo':
            contours.append([])
        contours[-1].append(op)
    return contours


def main():
    package_dir = sys.argv[1]
    root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    font = TTFont(os.path.join(package_dir, 'font', 'lucide.ttf'))
    with open(os.path.join(package_dir, 'font', 'codepoints.json')) as f:
        codepoints = json.load(f)
    cmap = font.getBestCmap()
    glyphs = font.getGlyphSet()
    em = font['head'].unitsPerEm
    scale = GRID / em

    def write(name, lucide_name, filled):
        recording = DecomposingRecordingPen(glyphs)
        glyphs[cmap[codepoints[lucide_name]]].draw(recording)
        ops = recording.value
        if filled:
            ops = max(split_contours(ops), key=contour_area)
        svg_pen = SVGPathPen(glyphs, ntos=lambda v: f'{v:.3f}'.rstrip('0').rstrip('.'))
        pen = TransformPen(svg_pen, (scale, 0, 0, -scale, 0, GRID))
        for op, args in ops:
            getattr(pen, op)(*args)
        with open(os.path.join(root_dir, 'assets', 'icons', f'{name}.svg'), 'w') as f:
            f.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="{GRID}" height="{GRID}"'
                    f' viewBox="0 0 {GRID} {GRID}">'
                    f'<!-- Lucide "{lucide_name}"; see tools/icons/import-lucide.py -->'
                    f'<path d="{svg_pen.getCommands()}"/></svg>\n')

    for name, lucide_name in ICONS.items():
        write(name, lucide_name, filled=False)
    for name, lucide_name in FILLED_ICONS.items():
        write(name, lucide_name, filled=True)


if __name__ == '__main__':
    main()
