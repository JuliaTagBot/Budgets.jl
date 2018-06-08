using Budgets
@static if VERSION < v"0.7.0-DEV.2005"
    using Base.Test
else
    using Test
end

b = 0
e1 = 0
d1 = 0
p1 = 0

@testset "single" begin
    e1 = Event(Date(1001, 1, 1), "e", 2, Money(10))
    d1 = Event("d", Money(-5))
    p1 = Event(Date(999,9,9), Money(-5))
    b = Budget(Percentile(10))
    add!(b, e1)
    add!(b, d1)
    add!(b, p1)
    @test taxable(b) == Money(20)
    @test tax(b) == Money{Float64}(2)
    @test balance(b) == Money{Float64}(12)
end

@testset "mutliple" begin
    e2 = Event(Date(1000, 1, 1), "r", 3, Money(15))
    e3 = Event(Date(1002, 1, 1), "t", 6, Money(34.5))
    add!(b, e2, e3)
    @test expenses(b) == [e2, e1, e3]
    @test deductions(b) == [d1]
    @test payments(b) == [p1]
end

@testset "in" begin 
    events = ["e: 1-1-1, e1, 12, 44.4", "d: yea, -44.4", "p: 2014-11-11, -44.4"]
    b = Budget(Percentile(14))
    add!(b, define_event.(events)...)
    @test balance(b) == Money(12*44.4*1.14-44.4-44.4)
end

@testset "out" begin
    @test print(b) == "January 1, 1 & e1 & 12 & 44.4 sek & 532.8 sek \\\\\n\\hline\n & Total & & & 532.8 sek\\\\\n & VAT (14\\%) & & &74.59 sek\\\\\n & yea & & & -44.4 sek\\\\\nNovember 11, 2014 & Payment & & & -44.4 sek\\\\\n& Balance due & & & 518.59 sek\\\\"
end

@testset "missing" begin
    e4 = "e: , e1, 2, 50"
    b = Budget(Percentile(10))
    add!(b, define_event(e4))
    @test balance(b) == Money{Float64}(110)
end
