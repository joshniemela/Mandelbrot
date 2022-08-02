using CUDA, GLMakie, BenchmarkTools

const MAX_STEPS = 500
function mandelbrot(c)
    z = n = 0
    while abs2(z) < 4 && n < MAX_STEPS
        z = z^2+c
        n += 1
    end
    return n
end

X_MIN = -2.0
X_MAX = 0.6
Y_MIN = -1.5
Y_MAX = 1.5
aspect_ratio = (X_MAX-X_MIN)/(Y_MAX-Y_MIN)

PIXELS = 1e6

fig = Figure()
x = collect(LinRange(X_MIN, X_MAX, round(Int, aspect_ratio*sqrt(PIXELS), RoundUp)))
y = collect(LinRange(Y_MIN, Y_MAX, round(Int, 1/aspect_ratio*sqrt(PIXELS), RoundUp)))
z = CuArray((x.+(y*im)')) #produce the big grid of stuff
heat = Array(map(mandelbrot, z))


fig

X_MIN = Observable(X_MIN)
X_MAX = Observable(X_MAX)
Y_MIN = Observable(Y_MIN)
Y_MAX = Observable(Y_MAX)
PIXELS = Observable(PIXELS) 

heat = @lift begin
    aspect_ratio = ($X_MAX-$X_MIN)/($Y_MAX-$Y_MIN)
    x = collect(LinRange($X_MIN, $X_MAX, round(Int, aspect_ratio*sqrt($PIXELS), RoundUp)))
    y = collect(LinRange($Y_MIN, $Y_MAX, round(Int, 1/aspect_ratio*sqrt($PIXELS), RoundUp)))
    z = CuArray((x.+(y*im)')) #produce the big grid of stuff
    Array(map(mandelbrot, z))

end
on(events(fig).keyboardbutton) do event
    y_diff = Y_MAX[]-Y_MIN[]
    x_diff = X_MAX[]-X_MIN[]
    if ispressed(fig, Keyboard.w)
        Y_MAX[]=Y_MAX[]+.05y_diff
        Y_MIN[]=Y_MIN[]+.05y_diff
    end
    if ispressed(fig, Keyboard.s)
        Y_MAX[]=Y_MAX[]-.05y_diff
        Y_MIN[]=Y_MIN[]-.05y_diff
    end
    if ispressed(fig, Keyboard.a)
        X_MAX[]=X_MAX[]-.05x_diff
        X_MIN[]=X_MIN[]-.05x_diff
    end
    if ispressed(fig, Keyboard.d)
        X_MAX[]=X_MAX[]+.05x_diff
        X_MIN[]=X_MIN[]+.05x_diff
    end
    if ispressed(fig, Keyboard.i)
        X_MAX[]=X_MAX[]-.15x_diff
        X_MIN[]=X_MIN[]+.15x_diff
        Y_MAX[]=Y_MAX[]-.15y_diff
        Y_MIN[]=Y_MIN[]+.15y_diff
    end
    if ispressed(fig, Keyboard.o)
        X_MAX[]=X_MAX[]+.15x_diff
        X_MIN[]=X_MIN[]-.15x_diff
        Y_MAX[]=Y_MAX[]+.15y_diff
        Y_MIN[]=Y_MIN[]-.15y_diff
    end
    #println(aspect_ratio)
end
ax = Axis(fig[1,1])
heatmap!(ax, x, y, heat, colormap = (:dense))
fig
#@btime A * A
#@btime A_d * A_d