using CairoMakie
using CairoMakie: Polygon

hex_to_pixel(q, r, s) = (sqrt(3) * q + sqrt(3) / 2 * r), -3 / 2 * r

function add_hex(q, r, s)
    x, y = hex_to_pixel(q, r, s)
    return Polygon(Point2f[(x + cos(a), y + sin(a)) for a in range(0, 2pi; length=7)[1:6] .+ pi/6])
end

clr = CairoMakie.Makie.wong_colors()

let p = Figure(; size=(1600,600))
    ax = Axis(p[1, 1])
    ax2 = Axis(p[1, 2])
    L = 4
    
    for q in -20:20, r in -3:3
        s = -(q + r)
        s in -2:(L + 1) || continue
        
        # wrap around circle?
        d, m = divrem(q, L)
        
        s′ = mod1(s, L)
        q′ = q + (s - s′)÷2
        r′ = r + (s - s′)÷2

        
        
        poly!(ax, add_hex(q, r, s); color=clr[mod1(q + r, L)])
        # poly!(ax2, add_hex(q, r, s); color=clr[mod1((q′ - s′) ÷ 2, L)])
        poly!(ax2, add_hex(q, r, s); color=clr[mod1(q′ + r′, L)])
        
        text!(ax, hex_to_pixel(q, r, s)...; text="$q, $r, $s", align=(:center, :center))
        text!(ax2, hex_to_pixel(q, r, s)...; text="$q′, $r′, $s′", align=(:center, :center))
    end
    p
end

poly!(x, hexmarker)

p