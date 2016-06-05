import java.time.LocalDate;

/**
 * Created by Michal Stobierski on 2016-06-04.
 */

public class WynikiEgzaminow {

    static final int OCZEKIWANIE = 21;

    int id_egzaminu;
    int id_kierowcy;
    String wynik;

    // pola pomocnicze, nie uwzgledniane w krotce
    LocalDate data_przeprowadzenia;

    public WynikiEgzaminow(int id_kierowcy, String wynik, LocalDate data, String rodzaj) {
        this.id_kierowcy = id_kierowcy;
        this.wynik = wynik;

        for (int i = 0; i < OCZEKIWANIE; ++ i){
            if(Dane.egzaminyDaty.containsKey(data)){
                this.id_egzaminu = Dane.egzaminyDaty.get(data);
                if(Dane.egzaminyTypy.get(id_egzaminu) == rodzaj){
                    this.data_przeprowadzenia = data;
                    if(Dane.egzaminyObecnosc.get(id_egzaminu).contains(id_kierowcy) == false){
                        Dane.egzaminyObecnosc.get(id_egzaminu).add(id_kierowcy);
                        return;
                    }
                }
            }
            data.plusDays(1);
        }
        Egzaminy nowy = new Egzaminy(data, rodzaj);
        Dane.egzaminy.add(nowy);
        Dane.egzaminyTypy.put(nowy.getId_egzaminu(), nowy.getTyp());
        Dane.egzaminyDaty.put(data, nowy.getId_egzaminu());
        this.data_przeprowadzenia = data;
        this.id_egzaminu = nowy.getId_egzaminu();
        Dane.egzaminyObecnosc.get(id_egzaminu).add(id_kierowcy);
    }

    public LocalDate getData() {
        return data_przeprowadzenia;
    }

    @Override
    public String toString() {
        return "(" +
                id_egzaminu +
                ", " + id_kierowcy +
                ", '" + wynik +
                "')";
    }
}
