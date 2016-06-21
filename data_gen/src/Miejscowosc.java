import java.util.HashMap;
import java.util.Map;

/**
 * Created by Michal Stobierski on 2016-06-12.
 */

public class Miejscowosc {

    public static Map<String, Integer> listId = new HashMap<>();
    static int objects;
    int id_miejscowosci;
    //String id_powiatu;
    String nazwa;

    public Miejscowosc(String dane) {

        String[] info = dane.split("[|]");
        id_miejscowosci = ++objects;

        //id_powiatu = Powiat.getId_powiatu(info[0]);
        if (info.length > 1) {
            nazwa = info[1];
        } else {
            nazwa = info[0];
        }

        listId.put(nazwa, id_miejscowosci);
    }

    public static Integer getId_miejscowosci(String nazwa) {
        return listId.get(nazwa);
    }

    public int getId_miejscowosci() {
        return id_miejscowosci;
    }

    @Override
    public String toString() {
        return "(" +
                "" + id_miejscowosci +
                ", '" + nazwa +
                "')";
    }
}
