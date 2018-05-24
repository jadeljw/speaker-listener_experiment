% shuffle
function [Shuffle_A,Shuffle_B]=U_Shuffle_for_surrogate(A,B)
    Shuffle_A = Shuffle(A);
    Shuffle_B = Shuffle(B);

for i = 1 : length(Shuffle_A)
    
    if Shuffle_A(i)==Shuffle_B(i)
        tempA = Shuffle_A(i);
        Shuffle_A(i)=Shuffle_A(i+1);
        Shuffle_A(i+1)=tempA;
    end
end

