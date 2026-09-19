p = 'tools/generate_all_screenshots.js'
s = open(p, encoding='utf-8', newline='').read().replace('\r\n', '\n')
start = s.index("    rows.push({ f: 1.0, draw: (y, ch) => card(y, ch, '#101E32', cardBorder, (x0, yy) =>\n      R(x0, yy + ch / 2 - 45 * s")
end = s.index("    rows.push({ f: 1.0, draw: (y, ch) => {\n      const third")
s = s[:start] + s[end:]
open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('removed steps card')
