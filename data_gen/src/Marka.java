import java.util.HashMap;
import java.util.Map;

/**
 * Created by Michal Stobierski on 2016-06-12.
 */

public class Marka {

    public static Map<String, Integer> listId = new HashMap<>();
    static int objects;
    int id_marka;
    String marka;

    public Marka(String dane) {

        String[] tab = dane.split("[|]");

        id_marka = ++objects;
        marka = tab[0];
        listId.put(marka, id_marka);
    }

    public static Integer getId_marka(String nazwa) {
        return listId.get(nazwa);
    }

    @Override
    public String toString() {
        return "(" +
                "" + id_marka +
                ", '" + marka +
                "')";
    }
}
