package controllers;

import database.Database;
import database.Vehicle;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.*;

public class VehiclesController {
    @FXML
    private TableView<?> tableView;
    @FXML
    private Button addButton;
    @FXML
    private Button moreInfoButton;

    @FXML
    private TextField id_pojazduTextField;
    @FXML
    private TextField nr_rejestracjiTextField;
    @FXML
    private TextField nr_VINTextField;
    @FXML
    private TextField id_markiTextField;
    @FXML
    private TextField typTextField;
    @FXML
    private TextField id_krajuTextField;
    @FXML
    private TextField waga_samochoduTextField;
    @FXML
    private DatePicker data_rejestracjiPicker;


    @FXML
    public void addVehicle(final ActionEvent event) {
        // TODO: adding vehicle to database using text fields
    }

    public void initialize() {
		data_rejestracjiPicker.setTooltip(new Tooltip("Data rejestracji pojazdu"));
		Database.instance.getVehiclesTable((TableView<Vehicle>) tableView);

    }

    @FXML
    public void showMoreInfo(final ActionEvent event) {
        // TODO: show more info about vehicles - some statistic, how many cars in each type, itp.
    }
}
