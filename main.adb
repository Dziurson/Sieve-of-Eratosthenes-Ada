with Ada.Execution_Time, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar, Ada.Strings.Unbounded;
use  Ada.Execution_Time, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Calendar, Ada.Strings.Unbounded;
with erastotenes; use erastotenes;

procedure main is 	
	tab : TablicaWsk;
	T1, T2: Time;
	suma: Float;
	iloscProb : Integer := 1;
begin
        Put_Line("------------------------");
	for i in 1..9 loop
		suma := 0.0;
		for j in 1..iloscProb loop
			inicjuj(tab);
			T1 := Clock;
			policzAsync(tab, i);
			T2 := Clock;
			suma := suma + Float(T2-T1);
                
			Put(Character'Val(13) & "[");
			for k in 1..iloscProb loop
				if (k <= j) then Put("-"); else Put(" "); end if;
			end loop;
			Put("]");
		end loop;
		Put_Line(Character'Val(13) & "Wykonanie asynchroniczne dla" & Integer'Image(i) & " wątków -" & Integer'Image(iloscProb) & " pomiarów:    " & Integer'Image(Integer(suma / Float(IloscProb) * 1000.0)) & " ms.");                
		suma := 0.0;
		for j in 1..iloscProb loop
			inicjuj(tab);
			T1 := Clock;
			policzAsync2(tab, i, j, iloscProb);
			T2 := Clock;
			suma := suma + Float(T2-T1);

		end loop;
		Put_Line(Character'Val(13) & "Wykonanie asynchroniczne v2 dla" & Integer'Image(i) & " wątków -" & Integer'Image(iloscProb) & " pomiarów: " & Integer'Image(Integer(suma / Float(IloscProb) * 1000.0)) & " ms.");

		Put_Line("------------------------");
        end loop;
        wyswietl(tab,true,10000);
	
end main;