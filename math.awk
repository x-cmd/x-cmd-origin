
function math_abs(num) {
    return num < 0 ? -num : num;
}

function math_trunc(num) {
    return int(num);
}

function math_round(num, _tmp) {
    _tmp = int(num)
    if (num < 0) {
        return _tmp - ( (_tmp - num > 0.5) ? 1 : 0 )
    } else {
        return _tmp + ( (num - tmp > 0.5) ? 1 : 0 )
    }
}

function math_ceil(num) {
    if (num < 0) {
        return int(num);
    } else {
        return int(num) + (num == int(num) ? 0 : 1)
    }
}

function math_floor(num) {
    if (num < 0) {
        return int(num) - (num == int(num) ? 0 : 1)
    } else {
        return int(num)
    }
}


