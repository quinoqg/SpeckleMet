function transformed_vector = VectorShift(input_vector,shift_units)

transformed_vector = zeros(1,length(input_vector));

for index = shift_units+1:length(input_vector)

    transformed_vector(index) = input_vector(index - shift_units);

end

