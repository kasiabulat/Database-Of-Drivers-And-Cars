package Database;

/**
 Created by Kamil Rajtar on 02.06.16. */
public class Driver
{
	int id_kierowcy;
	String PESEL;
	String imię;
	String nazwisko;
	String email; /*CHECK*/
	String nr_telefonu; /*CHAR(9)?*/
	String adres;

	public Driver(final int id_kierowcy,final String PESEL,final String imię,final String nazwisko,final String email,final String nr_telefonu,final String adres)
	{
		this.id_kierowcy=id_kierowcy;
		this.PESEL=PESEL;
		this.imię=imię;
		this.nazwisko=nazwisko;
		this.email=email;
		this.nr_telefonu=nr_telefonu;
		this.adres=adres;
	}

	public int getId_kierowcy()
	{
		return id_kierowcy;
	}

	public void setId_kierowcy(final int id_kierowcy)
	{
		this.id_kierowcy=id_kierowcy;
	}

	public String getPESEL()
	{
		return PESEL;
	}

	public void setPESEL(final String PESEL)
	{
		this.PESEL=PESEL;
	}

	public String getImię()
	{
		return imię;
	}

	public void setImię(final String imię)
	{
		this.imię=imię;
	}

	public String getNazwisko()
	{
		return nazwisko;
	}

	public void setNazwisko(final String nazwisko)
	{
		this.nazwisko=nazwisko;
	}

	public String getEmail()
	{
		return email;
	}

	public void setEmail(final String email)
	{
		this.email=email;
	}

	public String getNr_telefonu()
	{
		return nr_telefonu;
	}

	public void setNr_telefonu(final String nr_telefonu)
	{
		this.nr_telefonu=nr_telefonu;
	}

	public String getAdres()
	{
		return adres;
	}

	public void setAdres(final String adres)
	{
		this.adres=adres;
	}
}
