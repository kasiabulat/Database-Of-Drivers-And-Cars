import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

public class Osrodki {

    static int objects = 0;
    static Random rNum = new Random();
    public static Map<String, Boolean> wytworzoneOsrodki = new HashMap<>();

    int id_osrodka;
    String nazwa;
    String adres;

    public Osrodki() {
        id_osrodka = ++objects;

        String[] osrodek = Dane.adresyOsrodkow.get(rNum.nextInt(Dane.adresyOsrodkow.size())).split(";");
        while(wytworzoneOsrodki.containsKey(osrodek[0])){
            osrodek = Dane.adresyOsrodkow.get(rNum.nextInt(Dane.adresyOsrodkow.size())).split(";");
        }
        nazwa = osrodek[0];
        adres = osrodek[1];
        wytworzoneOsrodki.put(nazwa, true);
    }

    public int getId_osrodka() {
        return id_osrodka;
    }

    public String toString() {
        return "(" +
                id_osrodka +
                ", '" + nazwa +
                "', '" + adres +
                "')";
    }
}
