package database.datatypes;

/**
 Created by Kamil Rajtar on 15.06.16. */
public class VehicleMarkModel
{
	public final String mark;
	public final String model;
	public final Integer count;

	public VehicleMarkModel(final String mark,final String model,final Integer count)
	{
		this.mark=mark;
		this.model=model;
		this.count=count;
	}
}
