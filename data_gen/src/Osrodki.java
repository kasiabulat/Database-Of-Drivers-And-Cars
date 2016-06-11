import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Created by Michal Stobierski on 2016-06-03.
 */

class Osrodki {

    private static final Random rNum = new Random();
    private static final Map<String, Boolean> wytworzoneOsrodki = new HashMap<>();
    private static int objects;
    private final int id_osrodka;
    private final String nazwa;
    private final String adres;

    public Osrodki() {
        id_osrodka = ++objects;

        String[] osrodek = Dane.adresyOsrodkow.get(rNum.nextInt(Dane.adresyOsrodkow.size())).split(";");
        while (wytworzoneOsrodki.containsKey(osrodek[0])) {
            osrodek = Dane.adresyOsrodkow.get(rNum.nextInt(Dane.adresyOsrodkow.size())).split(";");
        }
        nazwa = osrodek[0];
        adres = osrodek[1];
        wytworzoneOsrodki.put(nazwa, true);
    }

    public int getId_osrodka() {
        return id_osrodka;
    }

    @Override
    public String toString() {
        return "(" +
                id_osrodka +
                ", '" + nazwa +
                "', '" + adres +
                "')";
    }
}
