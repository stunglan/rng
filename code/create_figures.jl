# %%
using Distributions, Statistics, LinearAlgebra,DataFrames, StatsBase, Printf


using Random, Dates;
Random.seed!(2022);  # make sure this tutorial is reproducible

import Meshes

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
modeVar = x[argmax(pdf.(rv, x))]
println("modeVar=$modeVar  P50=$(quantile(rv, 0.5))  Mean=$(mean(rv))")
println("P10=$(quantile(rv, 0.1))  P50=$(quantile(rv, 0.5))  P90=$(quantile(rv, 0.9))")


fig = Figure(resolution=(1800, 600))
ax = Axis(fig[1, 1], title="12 ¼\" drilling", xlabel="days", ylabel="cumulative probability", limits=((0, 20), nothing))
hist!(ax, rand(rv, 100_0), normalization=:pdf, bins=100, color=(:green, 0.2), alpha=1)
lines!(ax, x, pdf.(rv, x), color=:red, linewidth=2)

lines!(ax, [modeVar, modeVar], [0, pdf(rv, modeVar)], linewidth=3, label="modeVar = $(round(modeVar; digits=2))")
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
scatter!(ax1,1:lentime,money_per_day,  color=(:black,1), )
tempo =string.(purchase_dates[slice_dates])
ax1.xticks = (slice_dates, tempo)
ax1.xticklabelrotation = pi / 4

fig
# %%

sum(money_per_day)

resamples = sample(money_per_day,(9999,length(money_per_day)),replace=true)


sum(resamples,dims=2)
sum(resamples[1,:])

fig = Figure(resolution=(800, 400), fonts=(; regular="Open Sans"))

axes = []

push!(axes,Axis(fig[1, 1]))
push!(axes,Axis(fig[1, 2]))
push!(axes,Axis(fig[1, 3]))
push!(axes,Axis(fig[2, 1]))
push!(axes,Axis(fig[2, 2]))
push!(axes,Axis(fig[2, 3]))

for (i,ax) in enumerate(axes)
    ax.title = string(round(sum(resamples[i,:]);digits=2))
    lines!(ax,1:lentime,resamples[i,:], linewidth=2, color=(:black,0.1), strokecolor=:black, strokewidth=4,)
    scatter!(ax,1:lentime,resamples[i,:],  color=(:black,1), )
    #tempo =string.(purchase_dates[slice_dates])
    ax.xticksvisible = false
    ax.xticklabelsvisible = false
    #ax.xticklabelrotation = pi / 4
end
fig

fig = Figure(resolution=(800, 400), fonts=(; regular="Open Sans"))

ax1 = Axis(fig[1, 1], title="Distribution of resampled sums", ylabel="samples", limits=(2500,15000,nothing,nothing),xlabel="NOK",xticks = 0:5000:14000)

hist!(ax1, vec(sum(resamples,dims=2)),normalization=:none, bins= 100,linewidth=2, color=cgrad(:tab10, 10)[1], strokecolor=:black, strokewidth=2)


ax3 = Axis(fig[1, 2],title="Cummulative distribution of resampled sums", limits=(2500,15000,nothing,nothing),xlabel="NOK",xticks = 0:5000:14000) 
v = vec(sum(resamples,dims=2))

bins =  bins = LinRange(0,15000,100)

mhist = fit(Histogram,v,bins)

bar_i = Vector{Float64}(undef,length(mhist.edges[1][2:end]))

for (i,bin) in enumerate(mhist.edges[1][2:end])
    println(i)
    bar_i[i] = sum(mhist.weights[1:i])
end

barplot!(ax3,mhist.edges[1][2:end],bar_i)
fig



# %% Wind farms



border_coords = [(0, 0), (0.05, 0.8), (0.2, 0.9), (0.2, 0.6), (0.4, 0.6),
                 (0.4, 0.9),(0.6, 1.0), (0.9, 1.0), (1.0, 0.2), (1, 0)]
border = Meshes.Ring(border_coords)

border |> Meshes.viz

area = Meshes.PolyArea(border)
area |> Meshes.viz



# 

struct WindFarm
    turbines::Meshes.PointSet
    area::Meshes.PolyArea
end

"""
plotsamples(wf::WindFarm)

Create a visualization of a wind farm with turbines and the area it covers.

Arguments:
- `wf::WindFarm`: a `WindFarm` object containing the turbines and the area.

Returns:
A `Figure` object with the visualization.
"""
function plotsamples(wf::WindFarm)
    title = "Objective $(@sprintf("%.4f",objective(wf)))"
    fig = Figure(resolution=(800, 700), fonts=(; regular="Open Sans"))
    ax1 = Axis(fig[1, 1], title=title)
    Meshes.viz!(wf.area; showfacets = false)
    if length(wf.turbines) > 0
        Meshes.viz!(wf.turbines; showfacets = false, color = :black,pointsize=30)
    end
    fig
end


"""
objective(points::Meshes.PointSet, area::Meshes.PolyArea)

Compute the objective function to minimize.

The objective is to maximize the minimum distance between the points in `points` and the boundary of the polygon `area`.
This function computes a smoothed version of the objective.

Arguments:
- `points::Meshes.PointSet`: a set of points to evaluate the objective on.
- `area::Meshes.PolyArea`: a polygon representing the area of interest.

Returns:
The value of the objective function.
"""
function objective(wf::WindFarm)
    searcher = Meshes.KNearestSearch(wf.turbines, 2)

    distances = Vector{Float64}(undef, length(wf.turbines))
    distance_outside = 0.0

    for (i,p) in enumerate(wf.turbines)
        inds, dists = Meshes.searchdists(p, searcher)
        distances[i] = dists[2]
        if p ∉ wf.area
            #println("outside $p")
            distance_outside += dists[2]
        end
    end
    #println("distance_outside $(1000*distance_outside)")
    ##println("distances exp mean  $(mean(exp.(-distances)))")
    #println("distances mean $(mean(distances))")
    distance_score = mean(exp.(-distances))  + 100*distance_outside

    #println(distances)
    sum(distance_score)
end


function permute_solution(points::Meshes.PointSet)
    scale = 0.05
    
    points = deepcopy(points)
    idx = rand(1:length(points))
    points.geoms[idx] = points.geoms[idx] |> Meshes.Translate(rand(Normal())*scale,rand(Normal())*scale)
    return points
end

"""Hill climbing algorithm"""
function climb(wf::WindFarm)
    ITERATIONS = 10^4
    points = deepcopy(wf.turbines)
    for iteration in 1:ITERATIONS
        new_points = permute_solution(points)
        if objective(WindFarm(new_points, wf.area)) < objective(WindFarm(points, wf.area))
            println("Iteration $iteration: $(objective(WindFarm(new_points, wf.area)))")
            points = new_points
            
        end
    end

    
    WindFarm(points, wf.area)

end


samples = rand(Uniform(), (2,25)) |> Meshes.PointSet
plotsamples(WindFarm(samples,area))
permute_solution(samples)
WindFarm(samples,area) |> climb |> plotsamples

# %%

"""Simple annealing algorithm"""
function annealing(wf::WindFarm)
    ITERATIONS = 10^4
    points = deepcopy(wf.turbines)
    for iteration in 1:ITERATIONS
        new_points = permute_solution(points)
        accept_worse = rand(Uniform()) < exp(-0.001 * iteration)
        if (objective(WindFarm(new_points, wf.area)) < objective(WindFarm(points, wf.area))) || accept_worse
            println("Iteration $iteration: $(objective(WindFarm(new_points, wf.area)))")
            points = new_points
            
        end
    end

    
    WindFarm(points, wf.area)

end

samples = rand(Uniform(), (2,25)) |> Meshes.PointSet
plotsamples(WindFarm(samples,area))
permute_solution(samples)
WindFarm(samples,area) |> annealing |> plotsamples

# %% Resampling correlations

using GLM
patient_height = vec(
    [
        160,
        172,
        167,
        185,
        162,
        163,
        175,
        177,
        185,
        165,
        162,
        182,
        173,
        162,
        167,
        172,
        170,
        177,
        170,
        168,
        163,
        178,
        158,
        182,
        157,
        167,
        160,
        170,
        170,
        160,
        177,
        182,
        166,
        168,
        170,
        155,
        148,
        175,
        175,
        168,
        160,
        180,
        153,
        175,
        185,
        145,
        165,
        170,
        165,
        175,
    ]
)

patient_pulse = vec(
    [
        68,
        116,
        80,
        80,
        84,
        95,
        80,
        80,
        80,
        76,
        80,
        100,
        92,
        88,
        92,
        90,
        80,
        90,
        80,
        90,
        80,
        80,
        80,
        76,
        80,
        80,
        78,
        84,
        90,
        80,
        80,
        80,
        72,
        80,
        80,
        80,
        82,
        104,
        76,
        80,
        84,
        68,
        70,
        84,
        80,
        64,
        82,
        84,
        84,
        72,
    ]
)

ols = lm(@formula(patient_pulse ~ patient_height), DataFrame(patient_pulse = patient_pulse, patient_height = patient_height))


coef(ols)

v = [minimum(patient_height),maximum(patient_height)]

fig = Figure(resolution=(800, 400), fonts=(; regular="Open Sans"))
ax = Axis(fig[1, 1], title="Correlation $(@sprintf("%.4f",cor(patient_height,patient_pulse)))", ylabel="Pulse", xlabel="Height")
scatter!(ax,patient_height,patient_pulse,  color=(:lightblue,1), )
lines!(ax,v,predict(ols,DataFrame(patient_height = v)),  color=(:red,1), )

println(" intercept: $(coef(ols)[1]), slope $(coef(ols)[2])")
println("paerson $(cor(patient_height,patient_pulse))")

function bootstrap(std, data, sampling)
    newx = []
    for i in 1:sampling.n
        sample = rand(data, sampling.n)
        ols = lm(@formula(patient_pulse ~ patient_height), sample)
        push!(newx,rand(Normal(coef(ols)[1],std),1)[1])
    end
    return newx
end

function takesample(patient_height,patient_pulse, n)
    new_height = []
    new_pulse = []
    for i in 1:n
        msample = rand(1:length(patient_height), 1)
        println(msample)
        push!(new_height,patient_height[msample[1]])
        push!(new_pulse,patient_pulse[msample[1]])
    end
    return new_height,new_pulse
end

takesample(patient_height,patient_pulse, 50)




fig = Figure(resolution=(800, 400), fonts=(; regular="Open Sans"))

grid = GridLayout()
grid[1:3,1:3] = [Axis(fig) for i in 1:3, j in 1:3]

for ax in CartesianIndex(grid)
    println(ax)
    #scatter!(ax,patient_height,patient_pulse,  color=(:lightblue,1), )
end


ax = Axis(fig[1, 1], title="Correlation $(@sprintf("%.4f",cor(patient_height,patient_pulse)))", ylabel="Pulse", xlabel="Height")
scatter!(ax,patient_height,patient_pulse,  color=(:lightblue,1), )
scatter!(ax,newx,predict(ols,DataFrame(patient_height = newx)),  color=(:red,1), )
fig

