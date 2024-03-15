amounts = [30, 70, 65, 30, 5]
intervals = [(21, 23), (23, 25), (25, 27), (27, 29), (29, 31)]

function average(intervals, amounts)
    N = sum(amounts)
    result = 0.0
    for i in 1:length(amounts)
        dz = (intervals[i][1] + intervals[i][2]) / 2
        result += dz * amounts[i] / N
    end
    return result
end

average(intervals, amounts)

function dispersion(intervals, amounts)
    N = sum(amounts)
    result = 0.0
    avg = average(intervals, amounts)
    for i in 1:length(amounts)
        dz = (intervals[i][1] + intervals[i][2]) / 2
        result += (dz - avg)^2 * amounts[i] / N
    end
    return result
end

dispersion(intervals, amounts)