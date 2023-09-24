# %%
using Distributions, Statistics, LinearAlgebra,DataFrames

using Random;
Random.seed!(2022);  # make sure this tutorial is reproducible

using CairoMakie

CairoMakie.activate!()
#GLMakie.set_window_config!(float=true)


# Knut's figures


rv = LogNormal(log(2.5), 1) .+ 1.5

p = 0.99
quantile(rv, p)

pdf.(rv, [1.2, 3.0])

x = LinRange(0.0, quantile(rv, p), 2^10)
mode = x[argmax(pdf.(rv, x))]
println("Mode=$mode  P50=$(quantile(rv, 0.5))  Mean=$(mean(rv))")
println("P10=$(quantile(rv, 0.1))  P50=$(quantile(rv, 0.5))  P90=$(quantile(rv, 0.9))")

# probability plot
fig = Figure(resolution=(1800, 600))
ax = Axis(fig[1, 1], title="12 ¼\" drilling", xlabel="days", ylabel="cumulative probability", limits=((0, 20), nothing))
hist!(ax, rand(rv, 100_0), normalization=:pdf, bins=100, color=(:green, 0.2), alpha=1)
lines!(ax, x, pdf.(rv, x), color=:red, linewidth=2)

lines!(ax, [mode, mode], [0, pdf(rv, mode)], linewidth=3, label="Mode = $(round(mode; digits=2))")
lines!(ax, [quantile(rv, 0.5), quantile(rv, 0.5)], [0, pdf(rv, quantile(rv, 0.5))], linewidth=3, label="Median = $(round(quantile(rv, 0.5); digits=2))")
lines!(ax, [mean(rv), mean(rv)], [0, pdf(rv, mean(rv))], linewidth=3, label="Mean = $(round(mean(rv); digits=2))")
axislegend()
fig

# cumulative plot

fig = Figure(resolution=(800, 600), fonts=(; regular="Open Sans"))
ax = Axis(fig[1, 1], title="12 ¼\" drilling", xlabel="days", ylabel="probability density", limits=((0, 20), (0, 1)), yticks=[0.1, 0.5, 0.9])
lines!(ax, x, cdf.(rv, x), color=:red, linewidth=2)

for (i, p) in enumerate([0.1, 0.5, 0.9])
    arrows!(ax, [0], [p], [quantile(rv, p) - 0.2], [0], linewidth=3)
    lines!(ax, [quantile(rv, p), quantile(rv, p)], [0, p], linewidth=3, label="P$(Int(p*100)) = $(round(quantile(rv, p); digits=2))")
end

axislegend(position=:rb)
fig


# Normal, lognormal and triangular

distributions = ("Normal" => Normal(2, 1), "Lognormal" => LogNormal(log(3), 0.55), "Triangular" => TriangularDist(0, 3, 0.7))



fig = Figure(resolution=(1800, 600), fonts=(; regular="Open Sans"))


for (i, d) in enumerate(distributions)
    x = LinRange(0.0, quantile(d[2], 0.99), 1_000_000)
    println(quantile(d[2], 0.999))
    ax1 = Axis(fig[1, i], title=d[1], ylabel="pdf", limits=((0, quantile(d[2], 0.999)), nothing), yticklabelcolor=:blue)
    ax2 = Axis(fig[1, i], ylabel="cdf", limits=((0, quantile(d[2], 0.99)), nothing), yticks=[0.1, 0.5, 0.9], yticklabelcolor=:red, yaxisposition=:right)
    lines!(ax1, x, pdf.(d[2], x), color=:blue, linewidth=2)
    lines!(ax2, x, cdf.(d[2], x), color=:red, linewidth=2)


end
fig


# Add uniform distributions

names = ["X", "Y", "Z"]

fig = Figure(resolution=(1800, 600), fonts=(; regular="Open Sans"))

ax = []

for (i, d) in enumerate(names)
    push!(ax, Axis(fig[1, i], title=d, limits=((0, 5), (0, 1.3)), xgridvisible=false, ygridvisible=false))

end

ax[2].yticklabelsvisible = false
ax[3].yticklabelsvisible = false

poly!(ax[1], Point2f[(1, 0), (2, 0), (2, 1), (1, 1)], color=1, strokecolor=:black, strokewidth=1, colormap=:tab10, colorrange=(1, 10))
poly!(ax[2], Point2f[(1, 0), (2, 0), (2, 1), (1, 1)], color=2, strokecolor=:black, strokewidth=1, colormap=:tab10, colorrange=(1, 10))
poly!(ax[3], Point2f[(2, 0), (3, 1), (4, 0), (2, 0)], color=3, strokecolor=:black, strokewidth=1, colormap=:tab10, colorrange=(1, 10))

fig


# proper way

fig = Figure(resolution=(1800, 600), fonts=(; regular="Open Sans"))

distributions = [
    ("X" => Uniform(1, 2)),
    ("Y" => Uniform(1, 2)),
    ("Z" => TriangularDist(2, 4, 3)),
]

for (i, d) in enumerate(distributions)
    x = LinRange(0.0, quantile(d[2], 0.99) + 1, 1_000_000)
    println(quantile(d[2], 0.999))
    ax1 = Axis(fig[1, i], title=d[1], ylabel="pdf", limits=((0, quantile(d[2], 0.999) + 1), (0, 1.3)), yticklabelcolor=:blue, xgridvisible=false, ygridvisible=false)

    lines!(ax1, x, pdf.(d[2], x), linewidth=2, color=i, strokecolor=:black, strokewidth=1, colormap=:tab10, colorrange=(1, 10))
    band!(ax1, x, fill(0, length(x)), pdf.(d[2], x), alpha=0.2, color=cgrad(:tab10, 10)[i])
end
ax[2].yticklabelsvisible = false
ax[3].yticklabelsvisible = false
fig


# Add uniform by sampling


distributions = [
    ("X" => Uniform(1, 2)),
    ("Y" => Uniform(1, 2)),
    ("Z" => TriangularDist(2, 4, 3)),
]

samples = [
    rand(Uniform(1, 2), 1000),
    rand(Uniform(1, 2), 1000),
]
push!(samples, samples[1] + samples[2])

function q10(x)
    quantile(x, 0.1)
end


function q90(x)
    quantile(x, 0.9)
end

fig = Figure(resolution=(1800, 600), fonts=(; regular="Open Sans"))

for (i, d) in enumerate(distributions)
    x = LinRange(0.0, quantile(d[2], 0.99) + 1, 1_000_000)
    println(quantile(d[2], 0.999))
    ax1 = Axis(fig[1, i], title=d[1], ylabel="pdf", limits=((0, quantile(d[2], 0.999) + 1), (0, 1.3)), yticklabelcolor=:blue, xgridvisible=false, ygridvisible=false)

    lines!(ax1, x, pdf.(d[2], x), linewidth=2, color=i, strokecolor=:black, strokewidth=1, colormap=:tab10, colorrange=(1, 10))
    #band!(ax1, x, fill(0, length(x)), pdf.(d[2], x), alpha=0.2, color=cgrad(:tab10, 10)[i])
    hist!(ax1, samples[i], normalization=:pdf, color=cgrad(:tab10, 10)[i], alpha=0.2)

    scatter!(ax1, samples[i][1:250], rand(Uniform(), 250), color=:black, markersize=5, marker=:circle, strokecolor=:black, strokewidth=0.5)

    display(describe(DataFrame(sample = samples[i][1:250]),:all, q10 => :q10,q90 => :q90))

end
ax[2].yticklabelsvisible = false
ax[3].yticklabelsvisible = false
fig

display(describe(DataFrame(samples=rand(Uniform(), 1000)),:all, q10 => :q10,q90 => :q90))

df = DataFrame(samples=rand(Uniform(), 1000))
describe(df,quantile(0.1) => :q10)