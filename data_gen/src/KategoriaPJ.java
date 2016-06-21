/**
 * Created by Michal Stobierski on 2016-06-12.
 */

public class KategoriaPJ {

    static int objects;
    int id_kategoria;
    String kategoria;

    public KategoriaPJ(String nazwa) {

        id_kategoria = ++objects;
        kategoria = nazwa;

    }

    @Override
    public String toString() {
        return "(" +
                id_kategoria +
                ", '" + kategoria + '\'' +
                ')';
    }
}
