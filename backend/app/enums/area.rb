class Area < EnumMethods
  associate_values administrative: 0,
                   commercial: 1,
                   financial: 2,
                   human_resources: 3,
                   technology: 4
end