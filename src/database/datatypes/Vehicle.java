package database.datatypes;

/**
 * Created by Kamil Rajtar on 03.06.16.
 */
public class Vehicle {
    private int id_pojazdu;
    private String nr_rejestracyjny;
    private String data_rejestracji;
    private String marka;
    private String model;
    private String typ;

    public Vehicle(final int id_pojazdu, final String nr_rejestracyjny, final String data_rejestracji, final String marka, final String model, final String typ) {
        this.id_pojazdu = id_pojazdu;
        this.nr_rejestracyjny = nr_rejestracyjny;
        this.data_rejestracji = data_rejestracji;
        this.marka = marka;
        this.model = model;
        this.typ = typ;
    }

    public int getId_pojazdu() {
        return id_pojazdu;
    }

    public void setId_pojazdu(final int id_pojazdu) {
        this.id_pojazdu = id_pojazdu;
    }

    public String getNr_rejestracyjny() {
        return nr_rejestracyjny;
    }

    public void setNr_rejestracyjny(final String nr_rejestracyjny) {
        this.nr_rejestracyjny = nr_rejestracyjny;
    }

    public String getData_rejestracji() {
        return data_rejestracji;
    }

    public void setData_rejestracji(final String data_rejestracji) {
        this.data_rejestracji = data_rejestracji;
    }

    public String getMarka() {
        return marka;
    }

    public void setMarka(final String marka) {
        this.marka = marka;
    }

    public String getModel() {
        return model;
    }

    public void setModel(final String model) {
        this.model = model;
    }

    public String getTyp() {
        return typ;
    }

    public void setTyp(final String typ) {
        this.typ = typ;
    }
}