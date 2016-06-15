package database.datatypes;

/**
 Created by Kamil Rajtar on 14.06.16. */
public class DangerousDriver
{
	private String imię;
	private String nazwisko;
	private Integer ilość_mandatów;
	private Integer suma_punktów_karnych;

	public DangerousDriver(final String imię,final String nazwisko,final Integer ilość_mandatów,final Integer suma_punktów_karnych)
	{
		this.imię=imię;
		this.nazwisko=nazwisko;
		this.ilość_mandatów=ilość_mandatów;
		this.suma_punktów_karnych=suma_punktów_karnych;
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

	public Integer getIlość_mandatów()
	{
		return ilość_mandatów;
	}

	public void setIlość_mandatów(final Integer ilość_mandatów)
	{
		this.ilość_mandatów=ilość_mandatów;
	}

	public Integer getSuma_punktów_karnych()
	{
		return suma_punktów_karnych;
	}

	public void setSuma_punktów_karnych(final Integer suma_punktów_karnych)
	{
		this.suma_punktów_karnych=suma_punktów_karnych;
	}
}
