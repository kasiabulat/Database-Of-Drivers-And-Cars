import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-12.
 */

public class Model {

    private static final Random rNum = new Random();
    public static Map<String, Integer> listId = new HashMap<>();
    public static Map<String, String> listTyp = new HashMap<>();
    public static Map<String, Integer> listWaga = new HashMap<>();
    static int objects;
    int id_modelu;
    int id_marki;
    String model;
    int sposob_zasilania;
    int liczba_miejsc;
    String typ_kierownicy;
    String typ_pojazdu;
    int waga_pojazdu;

    public Model() {

        String tab = Dane.samochody.get(rNum.nextInt(Dane.samochody.size()));
        while (listId.containsKey(tab.split("[|]")[1])) {
            tab = Dane.samochody.get(rNum.nextInt(Dane.samochody.size()));
        }

        String[] dane = tab.split("[|]");
//System.out.println(tab);
        id_modelu = ++objects;
        id_marki = Marka.getId_marka(dane[0]);
        model = dane[1];
        //sposob_zasilania = dane[]
        liczba_miejsc = new Integer(dane[3]);
        typ_kierownicy = dane[2];

        if (typ_kierownicy.equals("L")) {
            typ_kierownicy = "po lewej";
        } else typ_kierownicy = "po prawej";

        typ_pojazdu = dane[5];
        waga_pojazdu = new Integer(dane[4]);

        int losuj_sposob = rNum.nextInt(100);
        if (losuj_sposob < 40) sposob_zasilania = 1;
        else if (losuj_sposob < 80) sposob_zasilania = 2;
        else if (losuj_sposob < 90) sposob_zasilania = 3;
        else if (sposob_zasilania < 95) sposob_zasilania = 4;
        else sposob_zasilania = 5;

        listId.put(model, id_modelu);
        listTyp.put(model, typ_pojazdu);
        listWaga.put(model, waga_pojazdu);


    }

    @Override
    public String toString() {
        return "(" +
                "" + id_modelu +
                ", " + id_marki +
                ", '" + model + '\'' +
                ", " + sposob_zasilania +
                ", " + liczba_miejsc +
                ", '" + typ_kierownicy + '\'' +
                ')';
    }
}
