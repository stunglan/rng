using Distributions,Statistics, LinearAlgebra

using Random; Random.seed!(2022);  # make sure this tutorial is reproducible

using CairoMakie

CairoMakie.activate!()
#GLMakie.set_window_config!(float=true)


# Knut's figures


rv = LogNormal(log(2.5), 1) .+ 1.5

p = 0.99
quantile(rv, p)

pdf.(rv, [1.2,3.])

x = LinRange(0.,quantile(rv, p),2^10)
mode = x[argmax(pdf.(rv, x))]
println("Mode=$mode  P50=$(quantile(rv, 0.5))  Mean=$(mean(rv))")
println("P10=$(quantile(rv, 0.1))  P50=$(quantile(rv, 0.5))  P90=$(quantile(rv, 0.9))")




fig = Figure(resolution = (1800, 600))
ax = Axis(fig[1,1], title = "12 ¼\" drilling",xlabel = "days",ylabel = "probability density",limits=((0, 20), nothing))
hist!(ax, rand(rv, 100_0), normalization = :pdf, bins = 100,color = (:green, 0.2),alpha=1)
lines!(ax, x, pdf.(rv, x), color = :red, linewidth = 2)

lines!(ax, [mode, mode], [0, pdf(rv,mode)],  linewidth = 3,label="Mode = $(round(mode; digits=2))")
lines!(ax, [quantile(rv, 0.5),quantile(rv, 0.5)], [0, pdf(rv,quantile(rv, 0.5))],  linewidth = 3,label="Median = $(round(quantile(rv, 0.5); digits=2))")
lines!(ax, [mean(rv), mean(rv)], [0, pdf(rv,mean(rv))],  linewidth = 3,label="Mean = $(round(mean(rv); digits=2))")
axislegend()
fig



