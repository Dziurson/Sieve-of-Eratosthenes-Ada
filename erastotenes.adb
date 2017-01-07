with Ada.Text_IO, Ada.Integer_Text_IO; use Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Numerics.Generic_Elementary_Functions; 
with Ada.Unchecked_Deallocation;

package body erastotenes is

    package Value_Functions is new Ada.Numerics.Generic_Elementary_Functions (Float);
    use Value_Functions; 
	procedure Free is new Ada.Unchecked_Deallocation(Object => Tablica, Name => TablicaWsk);

	procedure inicjuj(tab: in out TablicaWsk) is
	begin
		if tab /= null then
			Free(tab);
		end if;
		tab := new Tablica;
        tab(1) := inna;
        tab(2) := pierwsza;
        for i in Long_Long_Integer range 4..N loop
            if i mod 2 = 0 then
                tab(i) := zlozona;
            end if;
        end loop;
	end;

    procedure wyswietl(tab: in TablicaWsk; tylkoPierwsze: in Boolean) is 
    begin
        for i in Long_Long_Integer range 1..N loop
            if (tylkoPierwsze and then (tab(i) = pierwsza or else tab(i) = nieodwiedzona)) 
               or else not tylkoPierwsze then
                if (tab(i) = nieodwiedzona) then
                    tab(i) := pierwsza;
                end if;
                Put(Long_Long_Integer'Image(i));
                Put(": ");
                Put(Rodzaj'image(tab(i)));
                Put_Line(" ");
            end if;
        end loop;
        Put_Line("---------------------------");
    end;

	procedure policz(tab: in out TablicaWsk) is 
    aktualna, wielokrotnosc, pierwiastek : Long_Long_Integer;
    begin
        aktualna := 3;
        pierwiastek := Long_Long_Integer(Sqrt(Float(N)));
        while aktualna <= pierwiastek loop    
        
            while tab(aktualna) /= nieodwiedzona  loop
                aktualna := aktualna + 2;
            end loop;
            tab(aktualna) := pierwsza;
            wielokrotnosc := aktualna + aktualna;

            while wielokrotnosc <= N loop
                tab(wielokrotnosc) := zlozona;
                wielokrotnosc := wielokrotnosc + aktualna;
            end loop;
        end loop;
    end;

------------------------------------------------------------- WERSJA nr 1 ---

    task type przejdzTask is
		entry przejdz(start: in Long_Long_Integer; tab: in out TablicaWsk);
		entry zwroc;
		entry zakoncz;
	end przejdzTask;
	task body przejdzTask is
		wielokrotnosc, tmpStart : Long_Long_Integer;
		tmpTab : TablicaWsk;
	begin
        loop 
			select 
		        accept przejdz(start: in Long_Long_Integer; tab: in out TablicaWsk) do
					tmpStart := start	;		        
					wielokrotnosc := start + start;
					tmpTab := tab;
		        end przejdz;
				while wielokrotnosc <= N loop
			        tmpTab(wielokrotnosc) := zlozona;
			        wielokrotnosc := wielokrotnosc + tmpStart;
			    end loop;
			or
		        accept zwroc;
            or
                accept zakoncz;
                exit;
            end select;
        end loop;
	end;

	procedure policzAsync(tab: in out TablicaWsk; liczbaWatkow: in Integer) is 	
		taskTab : Array(1..liczbaWatkow) of przejdzTask;
    	aktualna, pierwiastek : Long_Long_Integer;
		iloscOdpalonych : Integer;
    begin

        aktualna := 3;
        pierwiastek := Long_Long_Integer(Sqrt(Float(N)));

		while aktualna <= pierwiastek loop    

			-- odpalenie wątków
			iloscOdpalonych := 0;
        	for i in taskTab'Range loop
				while tab(aktualna) /= nieodwiedzona loop
		            aktualna := aktualna + 2;
		        end loop;
					
		        tab(aktualna) := pierwsza;
				iloscOdpalonych := iloscOdpalonych + 1;
				taskTab(i).przejdz(aktualna, tab);
			end loop;
			
			-- czekanie na wątki			
        	for i in 1..iloscOdpalonych loop
				taskTab(i).zwroc;
			end loop;

		end loop;
		
		-- kończenie wątków
		for i in taskTab'Range loop
			taskTab(i).zakoncz;
		end loop;
    end;

------------------------------------------------------------- WERSJA nr 2 ---
	
	task type glownyTask is
		entry inicjuj(tab: in out TablicaWsk; liczbaWatkow: Integer; proba: Integer; iloscProb: Integer);
		entry koniecIteracji(index: Integer);
		entry koniec;
	end glownyTask;
	type glownyTaskWsk is access all glownyTask;

    task type przejdzTask2 is
		entry przejdz(start: Long_Long_Integer; tab: in out TablicaWsk; index: Integer; rodzic: glownyTaskWsk);
	end przejdzTask2;
	type przejdzTask2Wsk is access all przejdzTask2;
	type przejdzArray is array(Positive range <>) of przejdzTask2Wsk;
	type przejdzArrayWsk is access przejdzArray;

	task body przejdzTask2 is
		wielokrotnosc, tmpStart : Long_Long_Integer;
		tmpTab : TablicaWsk;
		tmpIndex : Integer;
		tmpRodzic : glownyTaskWsk;
	begin
		select 
		    accept przejdz(start: Long_Long_Integer; tab: in out TablicaWsk; index: Integer; rodzic: glownyTaskWsk) do
				tmpStart := start	;		        
				wielokrotnosc := start + start;
				tmpTab := tab;
				tmpRodzic := rodzic;
				tmpIndex := index;
		    end przejdz;
			while wielokrotnosc <= N loop
		        tmpTab(wielokrotnosc) := zlozona;
		        wielokrotnosc := wielokrotnosc + tmpStart;
		    end loop;
			tmpRodzic.koniecIteracji(tmpIndex);
        end select;
	end;


	task body glownyTask is
		taInstancja : glownyTaskWsk := glownyTask'Unchecked_Access;
		warunekKonca : Boolean := false;
		taski : przejdzArrayWsk;
                aktualna, pierwiastek: Long_Long_Integer;
                tmp_disp_val: Long_Long_Integer := 0;
                ilDzialajacychWatkow,pr,prmax : Integer;                
		tmpTab : TablicaWsk;
	begin
		loop
			select
				accept inicjuj(tab: in out TablicaWsk; liczbaWatkow: Integer; proba: Integer; iloscProb: Integer) do
                                    tmpTab := tab;
                                    pr := proba;
                                    prmax := iloscProb;
					taski := new przejdzArray(1 .. liczbaWatkow);
					ilDzialajacychWatkow := liczbaWatkow;
					aktualna := 3;
                                        pierwiastek := Long_Long_Integer(Sqrt(Float(N)));	
					for i in 1 .. liczbaWatkow loop
						while tmpTab(aktualna) /= nieodwiedzona loop
						    aktualna := aktualna + 2;
						end loop;
					
						tab(aktualna) := pierwsza;
						taski(i) := new przejdzTask2;
						taski(i).przejdz(aktualna, tmpTab, i, taInstancja);
					end loop;
				end inicjuj;
			or
				accept koniecIteracji(index: Integer) do
					if (aktualna <= pierwiastek) then
						while tmpTab(aktualna) /= nieodwiedzona loop
							aktualna := aktualna + 2;
                                                end loop;
                                                if tmp_disp_val = 0 then
                                                    Put(Character'Val(13) & "Proba : " & Integer'Image(pr) & " /" & Integer'Image(prmax) & " Postep:  0%  ");
                                                end if;
                                                if tmp_disp_val < (aktualna*100/pierwiastek) then
                                                    tmp_disp_val := aktualna*100/pierwiastek;
                                                    Put(Character'Val(13) & "Proba : " & Integer'Image(pr) & " /" & Integer'Image(prmax) & " Postep: " & Long_Long_Integer'Image(tmp_disp_val) & "%");
                                                end if;
						tmpTab(aktualna) := pierwsza;
						taski(index) := new przejdzTask2;
						taski(index).przejdz(aktualna, tmpTab, index, taInstancja);
					else 
						ilDzialajacychWatkow := ilDzialajacychWatkow - 1;
						if (ilDzialajacychWatkow <= 0) then
							warunekKonca := True;
						end if;
					end if;
				end koniecIteracji;
			or 
				when warunekKonca =>
					accept koniec;
					exit;
			end select;
		end loop;
	end;


	procedure policzAsync2(tab: in out TablicaWsk; liczbaWatkow: in Integer; proba: in Integer; iloscProb: in Integer) is 	
		glowny : glownyTaskWsk;
    begin
		glowny := new glownyTask;
		glowny.inicjuj(tab, liczbaWatkow, proba, iloscProb);
		glowny.koniec;
    end;

end erastotenes;
