package database.datatypes;

/**
 Created by Kamil Rajtar on 15.06.16. */
public class VehicleMarkModel
{
	public String mark;
	public String model;
	public Integer count;

	public VehicleMarkModel(String mark,String model,Integer count)
	{
		this.mark=mark;
		this.model=model;
		this.count=count;
	}
}
