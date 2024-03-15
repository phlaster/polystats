using CairoMakie, LaTeXStrings, PrettyTables

intervals = [(21, 23), (23, 25), (25, 27), (27, 29), (29, 31)]
freqs = [30, 70, 65, 30, 5]


let
    midpoints = [(b+a)/2 for (a,b) in intervals]
    a, b = intervals[1][1], intervals[end][2]
    n_intervals = length(intervals)
    ungroupped = vcat([fill(midpoints[i], freqs[i]) for i in 1:n_intervals]...)

    f = Figure(size = (700,500))

    ax1 = Axis(
        f[1, 1],
        xticks = 21:2:31,
        yticks = 0:0.02:0.18,
        
        xminorticksvisible = true,
        xminorgridvisible = true,

        yminorticksvisible = true,
        yminorgridvisible = true,

        yminorticks = IntervalsBetween(2),
        xminorticks = IntervalsBetween(2),
    )
    # ylims!(ax1, -0.015, 0.73)

    ax2 = Axis(
        f[1, 1],
        yaxisposition = :right,
        yminorticksvisible = true,

        xminorgridvisible = false,
        yminorgridvisible = false,

        xgridvisible = false,
        ygridvisible = false,

        yminorticks = IntervalsBetween(5),
    )
    ylims!(ax2, -0.05, 1.02)
    hidespines!(ax2)
    hidexdecorations!(ax2)
    
    h = hist!(ax1,
        ungroupped,
        normalization = :pdf,
        color = (:royalblue, 0.65),
        bins = [21:2:31;],
        strokewidth = 0.5,
        strokecolor = (:black, 0.4)
    )

    cdf = ecdfplot!(ax2,
        ungroupped,
        color = (:black, 0.65),
        linewidth = 3,
        step= :pre,
        npoints=6
    )
    Legend(f[1, 2],
        [h, cdf],
        ["Гистограмма", L"F_n(x)"]
    )
    # Label(
    #     f[0, :],
    #     "Графический анализ, вариант 1",
    #     fontsize = 22
    # )
    save("lab01/pic1.png", f)
    f
end

Σ = sum

function calculate_sample_mean(intervals, freqs)
    # Средние в интервалах
    midpoints = [(b+a)/2 for (a,b) in intervals]

    # умножить каждое среднее на соответствующую частоту,
    # сложить и поделить на общее число наблюдений
    sample_mean = Σ(freqs .* midpoints) / Σ(freqs)

    return sample_mean
end

function calculate_D(freqs, sample_mean)
    # Квадраты отклонений для каждого интервала
    squares = (freqs .- sample_mean).^2

    D = Σ(squares .* freqs) / (Σ(freqs)-1)

    return D
end

function calculate_cumsum(v)
    return [Σ(v[1:i]) for i in 1:length(v)]
end

function calculate_median(v, intervals)
    # общее число наблюдений
    N = Σ(v)
    
    # Половина
    half = N ÷ 2
    
    # Набегающая сумма 
    cumulative = calculate_cumsum(v)
    
    # Номер интервала, где лежит медиана
    n_interval = findfirst(>(half), cumulative) - 1
    
    # частота интервала
    f = freqs[n_interval]
    
    # Границы
    L,H = intervals[n_interval]
    
    # Ширина Интервала
    w = H-L
    
    # накопленная частота до
    F = Σ(freqs[1:n_interval-1])
    
    median =  L + w * (half-F)/f
    return median
end

function calculate_sqew(freqs, intervals, sample_mean, σ)
    midpoints = [(b+a)/2 for (a,b) in intervals]

    μ3 = Σ(freqs .* (midpoints .- sample_mean).^3)/Σ(freqs)

    return μ3/σ^3
end

function calculate_eccess(freqs, intervals, sample_mean, σ)
    midpoints = [(b+a)/2 for (a,b) in intervals]

    μ4 = Σ(freqs .* (midpoints .- sample_mean).^4)/Σ(freqs)

    return μ4/σ^4
end

sample_mean = calculate_sample_mean(intervals, freqs)
D = calculate_D(freqs, sample_mean)
σ = √D
med = calculate_median(freqs, intervals)
V = σ/sample_mean
sqew = calculate_sqew(freqs, intervals, sample_mean, σ)
eccess = calculate_eccess(freqs, intervals, sample_mean, σ)

data = Dict(
    "Выборочное среднее" => sample_mean,
    "Выборочная дисперсия" => D,
    "Стандартное отклонение" => σ,
    "Медиана" => med,
    "Коэффициент вариации" => V,
    "Коэффициент асимметрии" => sqew,
    "Эксцесс" => eccess
)
pretty_table(data)

let 
    intervals_new = [(i, i+2) for i in 21:1500]
    freqs_new = vcat([30, 70, 65, 30, 5], zeros(Int, 1474), 1)


    sample_mean_new = calculate_sample_mean(intervals_new, freqs_new)
    D_new = calculate_D(freqs_new, sample_mean_new)
    σ_new = √D_new
    med_new = calculate_median(freqs_new, intervals_new)
    V_new = σ_new/sample_mean_new
    sqew_new = calculate_sqew(freqs_new, intervals_new, sample_mean_new, σ_new)
    eccess_new = calculate_eccess(freqs_new, intervals_new, sample_mean_new, σ_new)

    data_new = Dict(
        "Выборочное среднее" => sample_mean_new,
        "Выборочная дисперсия" => D_new,
        "Стандартное отклонение" => σ_new,
        "Медиана" => med_new,
        "Коэффициент вариации" => V_new,
        "Коэффициент асимметрии" => sqew_new,
        "Эксцесс" => eccess_new
    );
    pretty_table(data_new)
    
end