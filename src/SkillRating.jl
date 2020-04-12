module SkillRating

    const q = log(10)/400

    g(rd) = 1/sqrt(1 + 3q^2 * (rd^2)/π^2)
    Es(r, r2, rd2) = 1/(1+10^(-g(rd2) * (r - r2) / 400))
    d2(r, rjs, RDjs) = 1/((q^2) * sum(g.(RDjs).^2 .* Es.(r, rjs, RDjs).* (1 .- Es.(r, rjs, RDjs))))

    """
        glicko_rating(r, RD, rjs::Vector, RDjs::Vector, sjs::Vector)
        glicko_rating(r, RD, rj::T, RDj::T, sj::T) where T <: Real
    
    # Arguments:
    * `r`: Rating of player
    * `RD`: Rating deviation of player
    * `rjs`: Ratings of oppenents within rating period.
    * `RDjs`: Rating devations of oppenents within rating period.
    * `sjs`: Game outcomes from the perspective of the "player": 1 - won, 0.5 - draw, 0 - lost.
    
    Calculate a new glicko rating for games within a rating period or for a single game.
    
    See: http://www.glicko.net/glicko/glicko.pdf and Glickman, Mark E., "Parameter estimation 
    in large dynamic paired comparison experiments" (1999) Applied Statistics, 48, 377-394
    (http://www.glicko.net/research/glicko.pdf)
    """
    glicko_rating(r, RD, rjs::Vector, RDjs::Vector, sjs::Vector) = r + q/(1/RD^2 + 1/d2(r, rjs, RDjs)) * sum(g.(RDjs) .* (sjs .- Es.(r, rjs, RDjs)))

    """
        glicko_RD(r, RD, rjs::Vector, RDjs::Vector, sjs::Vector)
        glicko_RD(r, RD, rj::T, RDj::T, sj::T) where T <: Real

    # Arguments:
    * `r`: Rating of player
    * `RD`: Rating deviation of player
    * `rjs`: Ratings of oppenents within rating period.
    * `RDjs`: Rating devations of oppenents within rating period.
    * `sjs`: Game outcomes from the perspective of the "player": 1 - won, 0.5 - draw, 0 - lost.

    Calculate a new glicko rating deviation for games within a rating period  or for a single game.
    
    See: http://www.glicko.net/glicko/glicko.pdf and 
    Glickman, Mark E., "Parameter estimation in large dynamic paired comparison experiments" (1999) Applied Statistics, 48, 377-394
    (http://www.glicko.net/research/glicko.pdf)
    """
    glicko_RD(r, RD, rjs::Vector, RDjs::Vector, sjs::Vector) = sqrt(1/(1/RD^2 + 1/d2(r, rjs, RDjs)))
    
    glicko_rating(r, RD, rj::T, RDj::T, sj::T) where T <: Real = glicko_rating(r, RD, [rj], [RDj], [sj])
    glicko_RD(r, RD, rj::T, RDj::T, sj::T) where T <: Real = glicko_RD(r, RD, [rj], [RDj], [sj])
    
    """
        glicko_RD_increase(rd; c = 63.2, maxrd=350)

    # Arguments:
    * `RD`: Rating deviation at end of rating period.
    * `c`: Increase in uncertainty between rating periods.
    * `maxRD`: Rating deviation of a player who does not play.

    Calculate rating deviation after the end of a rating period.
    
    See: http://www.glicko.net/glicko/glicko.pdf and 
    Glickman, Mark E., "Parameter estimation in large dynamic paired comparison experiments" (1999) Applied Statistics, 48, 377-394
    (http://www.glicko.net/research/glicko.pdf)
    """
    glicko_RD_increase(RD; c = 63.2, maxRD=350) = min(sqrt(RD^2+c^2), maxRD)

    """
        glicko_c(rating_perods_to_max, maxrd, medianrd)

    Calculate c, the increase in uncertainty between rating periods.
    
    See: http://www.glicko.net/glicko/glicko.pdf and 
    Glickman, Mark E., "Parameter estimation in large dynamic paired comparison experiments" (1999) Applied Statistics, 48, 377-394
    (http://www.glicko.net/research/glicko.pdf)
    """
    glicko_c(rating_perods_to_max, maxrd, medianrd) = sqrt((maxrd^2 - medianrd^2)/rating_perods_to_max)

    """
    elo_expected(RA, RB)

    # Arguments:
    * `RA`: Rating of player A
    * `RB`: Rating of player B

    Calculate the expected outcome using glicko.
    
    See: http://www.glicko.net/glicko/glicko.pdf and 
    Glickman, Mark E., "Parameter estimation in large dynamic paired comparison experiments" (1999) Applied Statistics, 48, 377-394
    (http://www.glicko.net/research/glicko.pdf)
    """
    glicko_expected(r1, RD1, r2, RD2) = 1 / (1 + 10^(-g(sqrt(RD1^2 + RD2^2)) * (r1 - r2)/400))

    """
        elo_rating(r, rjs::Vector, sjs::Vector; k = 32)

    # Arguments:
    * `r`: Rating of player
    * `rjs`: Ratings of oppenents within rating period.
    * `sjs`: Game outcomes from the perspective of the "player": 1 - won, 0.5 - draw, 0 - lost.

    Calculate the elo rating change.
    See: https://en.wikipedia.org/wiki/Elo_rating_system#Mathematical_details
    """
    elo_rating(r, rjs::Vector, sjs::Vector; k = 32) = r + k * (sum(sjs) - sum(elo_expected.(r, rjs)))

    """
    elo_expected(RA, RB)

    # Arguments:
    * `RA`: Rating of player A
    * `RB`: Rating of player B

    Calculate the expected outcome using elo.
    See: https://en.wikipedia.org/wiki/Elo_rating_system#Mathematical_details
    """
    elo_expected(RA, RB) = 1 / (1 + 10 ^ ((RB - RA) / 400))

    Eg2(μ, μj, ϕj) = 1/(1+exp(-gg2(ϕj)*(μ - μj)))
    gg2(ϕ) = 1/sqrt(1 + 3*(ϕ^2)/π^2)
    compute_v(μ, μjs, ϕjs) = 1/sum(gg2.(ϕjs).^2 .* Eg2.(μ, μjs, ϕjs) .* (1 .- Eg2.(μ, μjs, ϕjs)))
    compute_Δ(μ, μjs, ϕjs, sjs, v) = v * sum(gg2.(ϕjs) .* (sjs .- Eg2.(μ, μjs, ϕjs)))
    ϕincrease(ϕ, σ) = sqrt(ϕ^2 + σ^2)

    """
        glicko2(μ::Real, ϕ::Real, σ::Real, μjs::Vector{Real}, ϕjs::Vector{Real}, sjs::Vector{Real}; τ=0.05, ϵ=10^-6)
    
    # Arguments:
    * `μ`: Rating of player
    * `ϕ`: Rating deviation of player
    * `σ`: Rating volatility
    * `μjs`: Ratings of oppenents within rating period
    * `μjs`: Rating deviations within rating period
    * `sjs`: Game outcomes from the perspective of the "player": 1 - won, 0.5 - draw, 0 - lost.
    * `τ=0.5`: smaller values constrain the change in volatility over time, reasonable range between 0.3 and 1.2
    * `ϵ=10^-6`: Convergence bound

    Returns tuple `(μ, ϕ, σ)`: glicko2 rating, rating deviation and rating volatility for games in one rating period.

    See: http://www.glicko.net/glicko/glicko2.pdf and 
    Glickman, Mark E., "Dynamic paired comparison models with stochastic variances" (2001), 
    Journal of Applied Statistics, 28, 673-689. 
    (http://www.glicko.net/research/dpcmsv.pdf)
    """
    function glicko2(μ::Real, ϕ::Real, σ::Real, μjs::Vector{R}, ϕjs::Vector{R}, sjs::Vector{S}; τ=0.5, ϵ=10^-6) where {R <: Real, S <: Real}
        v = compute_v(μ, μjs, ϕjs)
        Δ = compute_Δ(μ, μjs, ϕjs, sjs, v) 
        a = log(σ^2)
        f(x) = exp(x)*(Δ^2 - ϕ^2  - v - exp(x)) / (2 * (ϕ^2 + v + exp(x))^2) - (x - a)/τ^2
        A = a
        if Δ^2 > ϕ^2 + v 
            B = log(Δ^2 - ϕ^2  - v)
        else
            k = 1
            while (f(a - k*τ) < 0)
                k += 1
            end
            B = a - k*τ
        end
        fA = f(A)
        fB = f(B)
        while abs(B - A) > ϵ
            C = A + (A-B) * fA/ (fB-fA)
            fC = f(C)
            if fC * fB < 0
                A = B
                fA = fB
            else
                fA /= 2
            end
            B = C
            fB = fC
        end
        σnew = exp(A/2)
        ϕincreased = sqrt(ϕ^2 + σnew^2)
        ϕnew = 1/sqrt(1/ϕincreased^2 + 1/v)
        μnew = μ + ϕnew^2 * sum(gg2.(ϕjs) .* (sjs .- Eg2.(μ, μjs, ϕjs)))
        μnew, ϕnew, σnew
    end

    """
        glicko1_to_glicko2(r::real, RD::Real)

    Convert ratings `r` and rating deviations `RD` from glicko1 (Elo-like) scale to glicko 2 scale (μ and ϕ).
    """
    glicko1_to_glicko2(r::Real, RD::Real) = ((r-1500)/173.7178, RD/173.7178)

    export glicko_rating, glicko_RD, glicko_RD_increase, glicko_c, glicko_expected, elo_rating, elo_expected, glicko2
end
