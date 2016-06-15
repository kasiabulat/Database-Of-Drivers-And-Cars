package database.datatypes;

/**
 Created by Kamil Rajtar on 14.06.16. */
public class ExamCenter
{
	String nazwa;
	String adres;
	Integer zdawało;
	Integer zdało;
	Double efektywność;

	public ExamCenter(final String nazwa,final String adres,final Integer zdawało,final Integer zdało,final Double efektywność)
	{
		this.nazwa=nazwa;
		this.adres=adres;
		this.zdawało=zdawało;
		this.zdało=zdało;
		this.efektywność=efektywność;
	}

	public String getNazwa()
	{
		return nazwa;
	}

	public void setNazwa(final String nazwa)
	{
		this.nazwa=nazwa;
	}

	public String getAdres()
	{
		return adres;
	}

	public void setAdres(final String adres)
	{
		this.adres=adres;
	}

	public Integer getZdawało()
	{
		return zdawało;
	}

	public void setZdawało(final Integer zdawało)
	{
		this.zdawało=zdawało;
	}

	public Integer getZdało()
	{
		return zdało;
	}

	public void setZdało(final Integer zdało)
	{
		this.zdało=zdało;
	}

	public Double getEfektywność()
	{
		return efektywność;
	}

	public void setEfektywność(final Double efektywność)
	{
		this.efektywność=efektywność;
	}
}
