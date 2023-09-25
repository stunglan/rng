# %%
using Distributions, Statistics, LinearAlgebra,DataFrames

using Random, Dates;
Random.seed!(2022);  # make sure this tutorial is reproducible

using CairoMakie, GLMakie

CairoMakie.activate!()
#GLMakie.activate!()
#GLMakie.set_window_config!(float=true)


# Knut's figures

# %% probability plot
rv = LogNormal(log(2.5), 1) .+ 1.5

p = 0.99
quantile(rv, p)

pdf.(rv, [1.2, 3.0])

x = LinRange(0.0, quantile(rv, p), 2^10)
mode = x[argmax(pdf.(rv, x))]
println("Mode=$mode  P50=$(quantile(rv, 0.5))  Mean=$(mean(rv))")
println("P10=$(quantile(rv, 0.1))  P50=$(quantile(rv, 0.5))  P90=$(quantile(rv, 0.9))")


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


# %% Normal, lognormal and triangular

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


# %% Add uniform distributions


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
    hist!(ax1, samples[i], normalization=:pdf, color=cgrad(:tab10, 10)[i], alpha=0.2)

    scatter!(ax1, samples[i][1:250], rand(Uniform(), 250), color=:black, markersize=5, marker=:circle, strokecolor=:black, strokewidth=0.5)

    display(describe(DataFrame(sample = samples[i][1:250]),:all, q10 => :q10,q90 => :q90))

end
ax[2].yticklabelsvisible = false
ax[3].yticklabelsvisible = false
fig



# %% General figures

# %% uniform distribution




distribution = Uniform()
x = LinRange(-0.05, 1.05,2^10)

samples = rand(distribution, 1000)


fig = Figure(resolution=(800, 600), fonts=(; regular="Open Sans"))

ax1 = Axis(fig[1, 1], title="Uniform", ylabel="pdf", limits=(nothing, (0, 1.2)), yticklabelcolor=:blue, xgridvisible=false, ygridvisible=false)

lines!(ax1, x, pdf.(distribution,x), linewidth=2, color=cgrad(:tab10, 10)[1], strokecolor=:black, strokewidth=2)
hist!(ax1, samples, normalization=:pdf, color=cgrad(:tab10, 10)[2], alpha=0.2)
scatter!(ax1, samples, rand(Uniform(), length(samples)) .* 0.2, color=:black, markersize=5, marker=:circle, strokecolor=:black, strokewidth=0.5)


fig


# %% normal distribution




distribution = Normal()
x = LinRange(-4, 4,2^10)

samples = rand(distribution, 1000)


fig = Figure(resolution=(800, 600), fonts=(; regular="Open Sans"))

ax1 = Axis(fig[1, 1], title="Normal", ylabel="pdf", limits=(nothing, (0, 0.45)), yticklabelcolor=:blue, xgridvisible=false, ygridvisible=false)

lines!(ax1, x, pdf.(distribution,x), linewidth=2, color=cgrad(:tab10, 10)[1], strokecolor=:black, strokewidth=2)
hist!(ax1, samples, normalization=:pdf, color=cgrad(:tab10, 10)[2], alpha=0.2)
scatter!(ax1, samples, rand(Uniform(), length(samples)) .* 0.2, color=:black, markersize=5, marker=:circle, strokecolor=:black, strokewidth=0.5)


fig

# %% Cannonball
# https://en.wikipedia.org/wiki/Projectile_motion

angle = deg2rad(45)
velocity = 10
g = 9.81

time_in_flight = 2 * velocity * sin(angle) / g

time = LinRange(0, time_in_flight, 2^5)

function  x_pos(t)
    return velocity * cos(angle) * t
end

function  y_pos(t)
    return velocity * sin(angle) * t - 0.5 * g * t^2
end 


fig = Figure(resolution=(500, 200), fonts=(; regular="Open Sans"))

ax1 = Axis(fig[1, 1], title="Cannonball", ylabel="pdf", limits=(nothing, nothing), yticklabelcolor=:blue, xgridvisible=false, ygridvisible=false)

lines!(ax1,x_pos.(time),y_pos.(time), linewidth=2, color=cgrad(:tab10, 10)[1], strokecolor=:black, strokewidth=2)
arrows!(ax1,[0],[0],[cos(angle) * velocity/5],[sin(angle) * velocity / 5], linewidth=2, color=:black, strokewidth=2)

fig


#  Cannonball with distribution

function final_position(angle, velocity, g)
    time_in_flight = 2 * velocity * sin(angle) / g
    return x_pos(time_in_flight)
end

RELATIVE_ERROR_ANGLE = 0.15

fig = Figure(resolution=(500, 200), fonts=(; regular="Open Sans"))

ax1 = Axis(fig[1, 1], title="Cannonball with distribution",  limits=(nothing, nothing), yticklabelcolor=:blue, xgridvisible=false, ygridvisible=false)

final_values = []

for iteration in 1:100
    angle = deg2rad(rand(Normal(45,0.15*45)))
    velocity = rand(Normal(10,0.01*10))

    arrows!(ax1,[0],[0],[cos(angle) * velocity/5],[sin(angle) * velocity / 5], linewidth=2, color=(:black,0.1), strokewidth=2)
    time_in_flight = 2 * velocity * sin(angle) / g
    time = LinRange(0, time_in_flight, 2^5)
    lines!(ax1,x_pos.(time),y_pos.(time), linewidth=2, color=(cgrad(:tab10, 10)[1],0.1), strokecolor=:black, strokewidth=2)

    push!(final_values,final_position(angle, velocity, g))

end

hist!(ax1,final_values, bins = 50, normalization=:pdf, scale_to=3.5, color=cgrad(:tab10, 10)[2], alpha=0.2)

fig


# %% Mutual fund savings
mutable struct MutualFundIterator
    yearly::Float64
    interest::Float64
    random_interest::Float64
    years::Int
    value::Float64
end
MutualFundIterator(yearly::Number,interest::Number, random_interest::Number, years::Int) = MutualFundIterator(yearly,interest, random_interest, years, 0)


Base.length(m::MutualFundIterator) = return m.years + 1
Base.eltype(::Type{MutualFundIterator}) = Float64

Base.iterate(m::MutualFundIterator) =  m.value, m

# Mutual fund savings interest changes random

function Base.iterate(m::MutualFundIterator, state::MutualFundIterator) 
    state.years -= 1
    state.value = state.value*rand(Normal(state.interest,state.random_interest)) + state.yearly
    if state.years < 0
        return nothing
    end
    return state.value,state
end

yearly = 12
interest = 1.05
years = 18

collect(MutualFundIterator(yearly, interest,0, years))

for (i,m) in enumerate(MutualFundIterator(12, 1.05,0.1, 18))
    println(i," ",m)
end


fig = Figure(resolution=(500, 200), fonts=(; regular="Open Sans"))

ax1 = Axis(fig[1, 1], title="Mutual Fund", ylabel="Money", xlabel="Years" ,limits=(nothing, nothing), yticklabelcolor=:black, xgridvisible=false, ygridvisible=false,xticks = 1:years)

for iteration in 1:100
    lines!(ax1,0:years,collect(MutualFundIterator(yearly, interest,0.1, years)), linewidth=2, color=(:black,0.1), strokecolor=:black, strokewidth=4,)
end

lines!(ax1,0:18,collect(MutualFundIterator(yearly, interest,0, years)), linewidth=2, color=(cgrad(:tab10, 10)[1],1), strokecolor=:black, strokewidth=2)


fig


# %% Groceries

money_per_day = 
    [
        0.0,
        0.0,
        471.9,
        784.22,
        0.0,
        355.29,
        0.0,
        600.76,
        399.7,
        0.0,
        266.7,
        238.6,
        433.0,
        0.0,
        1214.8,
        470.5,
        0.0,
        0.0,
        306.4,
        341.8,
        0.0,
        0.0,
        0.0,
        358.89,
        0.0,
        715.2,
        1049.02,
        0.0,
        0.0,
        536.7,
        367.7,
    ]

    purchase_dates = 
        [
            "2023-05-01",
            "2023-05-02",
            "2023-05-03",
            "2023-05-04",
            "2023-05-05",
            "2023-05-06",
            "2023-05-07",
            "2023-05-08",
            "2023-05-09",
            "2023-05-10",
            "2023-05-11",
            "2023-05-12",
            "2023-05-13",
            "2023-05-14",
            "2023-05-15",
            "2023-05-16",
            "2023-05-17",
            "2023-05-18",
            "2023-05-19",
            "2023-05-20",
            "2023-05-21",
            "2023-05-22",
            "2023-05-23",
            "2023-05-24",
            "2023-05-25",
            "2023-05-26",
            "2023-05-27",
            "2023-05-28",
            "2023-05-29",
            "2023-05-30",
            "2023-05-31",
        ]




lentime = length(money_per_day)
slice_dates = range(1, lentime, step=lentime ÷ 8)



fig = Figure(resolution=(500, 300), fonts=(; regular="Open Sans"))

ax1 = Axis(fig[1, 1], title="Groceries", ylabel="NOK", xlabel="Date")

lines!(ax1,1:lentime,money_per_day, linewidth=2, color=(:black,0.1), strokecolor=:black, strokewidth=4,)
tempo =string.(purchase_dates[slice_dates])
ax1.xticks = (slice_dates, tempo)
ax1.xticklabelrotation = pi / 4

fig

