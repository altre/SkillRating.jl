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
    See: http://www.glicko.net/glicko/glicko.pdf
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
    See: http://www.glicko.net/glicko/glicko.pdf
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
    See: http://www.glicko.net/glicko/glicko.pdf
    """
    glicko_RD_increase(RD; c = 63.2, maxRD=350) = min(sqrt(RD^2+c^2), maxRD)

    """
        glicko_c(rating_perods_to_max, maxrd, medianrd)

    Calculate c, the increase in uncertainty between rating periods.
    See: http://www.glicko.net/glicko/glicko.pdf
    """
    glicko_c(rating_perods_to_max, maxrd, medianrd) = sqrt((maxrd^2 - medianrd^2)/rating_perods_to_max)

    """
    elo_expected(RA, RB)

    # Arguments:
    * `RA`: Rating of player A
    * `RB`: Rating of player B

    Calculate the expected outcome using glicko.
    See: http://www.glicko.net/glicko/glicko.pdf
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

    export glicko_rating, glicko_RD, glicko_RD_increase, glicko_c, glicko_expected, elo_rating, elo_expected
end
