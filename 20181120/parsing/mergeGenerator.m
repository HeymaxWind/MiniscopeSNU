function merged = mergeGenerator(dayA, dayB)

rowSize = size(dayA,1);
colSize = size(dayA,2);

redChannel = zeros(rowSize, colSize, 1);
greenChannel = zeros(rowSize, colSize, 1);
blueChannel = zeros(rowSize, colSize, 1);

greenChannel = dayB;
redChannel = dayA;

merged  = uint8(cat(3, redChannel, greenChannel, blueChannel));

end