--[[

]]--


require 'cairo'

local status, cairo_xlib = pcall(require, 'cairo_xlib')
if not status then
    cairo_xlib = setmetatable({}, { __index = _G })
end




local function get_cpu_load()
    local cpu_load = conky_parse('${cpu}')
    cpu_load = tonumber(cpu_load)

    return cpu_load
end


local function draw_hal9000(cr, cx, cy, radius)
    local cpu_load = get_cpu_load()
    local r = (1 - math.exp(-cpu_load / 50)) * radius

    cairo_set_source_rgba(cr, 0, 0, 0, 1)
    cairo_arc(cr, cx, cy, radius, 0, 2 * math.pi)
    cairo_fill(cr)

    local pat = cairo_pattern_create_radial(cx, cy, r, cx, cy, radius)
    cairo_pattern_add_color_stop_rgba(pat, 0, 1, 0, 0, 1)
    cairo_pattern_add_color_stop_rgba(pat, 1, 0, 0, 0, 0)
    cairo_set_source(cr, pat)
    cairo_pattern_destroy(pat)
    cairo_paint(cr)

    cairo_set_source_rgba(cr, 1, 0.75, 0.75, 1)
    cairo_arc(cr, cx, cy, radius / 15, 0, 2 * math.pi)
    cairo_fill(cr)

    cairo_set_source_rgba(cr, 0.75, 0.75, 0.75, 1)
    cairo_set_line_width(cr, 7)
    cairo_arc(cr, cx, cy, radius, 0, 2 * math.pi)
    cairo_stroke(cr)
end



function conky_main()
    if conky_window == nil then return end

    local updates = conky_parse('${updates}')
    local n_updates = tonumber(updates)

    if n_updates < 1 then return end

    local cs = cairo_xlib_surface_create (conky_window.display,
                                          conky_window.drawable,
                                          conky_window.visual,
                                          conky_window.width,
                                          conky_window.height)
    local cr = cairo_create (cs)

    local cx = conky_window.width / 2
    local cy = conky_window.height / 2
    local radius = math.min(conky_window.width, conky_window.height) / 2 - 5

    draw_hal9000(cr, cx, cy, radius)

    cairo_destroy (cr)
    cairo_surface_destroy (cs) 
end

