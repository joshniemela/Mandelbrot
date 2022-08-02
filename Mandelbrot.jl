using CUDA, GLMakie, BenchmarkTools

const MAX_STEPS = 500
function mandelbrot(c)
    z = zero(c)
    n = 0
    while abs2(z) < 4 && n < MAX_STEPS
        z = z^2+c
        n += 1
    end
    return n
end

X_MIN = Observable(-2.0)
X_MAX = Observable(0.6)
Y_MIN = Observable(-1.5)
Y_MAX = Observable(1.5)
PIXELS = Observable(1e6)


fig = Figure()
ax = Axis(fig[1,1])

heat = @lift begin
    aspect_ratio = ($X_MAX-$X_MIN)/($Y_MAX-$Y_MIN)
    x = collect(LinRange($X_MIN, $X_MAX, round(Int, aspect_ratio*sqrt($PIXELS), RoundUp)))
    y = collect(LinRange($Y_MIN, $Y_MAX, round(Int, 1/aspect_ratio*sqrt($PIXELS), RoundUp)))
    z = CuArray(x.+(y*im)') #produce the big grid of stuff
    Array(map(mandelbrot, z))

end

on(events(fig).keyboardbutton) do event
    y_length = Y_MAX[]-Y_MIN[]
    x_length = X_MAX[]-X_MIN[]
    if ispressed(fig, Keyboard.w)
        Y_MAX[]=Y_MAX[]+.05y_length
        Y_MIN[]=Y_MIN[]+.05y_length
    end
    if ispressed(fig, Keyboard.s)
        Y_MAX[]=Y_MAX[]-.05y_length
        Y_MIN[]=Y_MIN[]-.05y_length
    end
    if ispressed(fig, Keyboard.a)
        X_MAX[]=X_MAX[]-.05x_length
        X_MIN[]=X_MIN[]-.05x_length
    end
    if ispressed(fig, Keyboard.d)
        X_MAX[]=X_MAX[]+.05x_length
        X_MIN[]=X_MIN[]+.05x_length
    end
    if ispressed(fig, Keyboard.i)
        X_MAX[]=X_MAX[]-.15x_length
        X_MIN[]=X_MIN[]+.15x_length
        Y_MAX[]=Y_MAX[]-.15y_length
        Y_MIN[]=Y_MIN[]+.15y_length
    end
    if ispressed(fig, Keyboard.o)
        X_MAX[]=X_MAX[]+.15x_length
        X_MIN[]=X_MIN[]-.15x_length
        Y_MAX[]=Y_MAX[]+.15y_length
        Y_MIN[]=Y_MIN[]-.15y_length
    end
end

heatmap!(ax, heat, colormap = (:dense), interpolate=true)

fig
