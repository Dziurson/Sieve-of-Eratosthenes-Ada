package erastotenes is   
		
    type Rodzaj is (nieodwiedzona, zlozona, pierwsza, inna);

	N : constant Long_Long_Integer := 100_000_000; -- Ilość sprawdzonych liczb
	
	type Tablica is array (1..N) of Rodzaj;
 	type TablicaWsk is access Tablica;

	procedure inicjuj(tab: in out TablicaWsk);

	procedure wyswietl(tab: in TablicaWsk; tylkoPierwsze: in Boolean);

	procedure policz(tab: in out TablicaWsk);

	procedure policzAsync(tab: in out TablicaWsk; liczbaWatkow: in Integer);

	procedure policzAsync2(tab: in out TablicaWsk; liczbaWatkow: in Integer; proba: Integer; iloscProb: Integer);

end erastotenes;
