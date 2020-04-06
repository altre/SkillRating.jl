using Test
using SkillRating

@testset "glicko" begin
    @test round(glicko_rating(1500, 200, [1400, 1550, 1700], [30, 100, 300], [1, 0, 0])) == 1464
    @test round(glicko_RD(1500, 200, [1400, 1550, 1700], [30, 100, 300], [1, 0, 0]), digits = 1) == 151.4
    @test round(glicko_expected(1400, 80, 1500, 150), digits = 3) == 0.376

    @test round(elo_rating(1613, [1609, 1477, 1388, 1586, 1720], [0,0.5,1,1,0])) == 1601
    @test round(elo_expected(1613, 1609), digits=2) == 0.51
end