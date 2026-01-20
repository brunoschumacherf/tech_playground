class TempoDeEmpresa < EnumMethods
  associate_values less_than_1_year: 0,
                   between_1_and_2_years: 1,
                   between_2_and_5_years: 2,
                   more_than_5_years: 3
end