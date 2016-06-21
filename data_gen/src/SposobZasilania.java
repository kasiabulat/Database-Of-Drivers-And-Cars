import java.util.HashMap;
import java.util.Map;

/**
 * Created by Michal Stobierski on 2016-06-12.
 */

public class SposobZasilania {

    public static Map<String, Integer> listId = new HashMap<>();
    static int objects;
    int id_sposob;
    String nazwa;

    public SposobZasilania(String dane) {

        id_sposob = ++objects;
        nazwa = dane;
        listId.put(nazwa, id_sposob);
    }

    @Override
    public String toString() {
        return "(" +
                "" + id_sposob +
                ", '" + nazwa +
                "')";
    }
}
