package controllers;

import database.Database;
import database.Driver;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.stage.Stage;

import java.io.IOException;

public class FirmsController {
    @FXML
    private TableView<?> tableView;
    @FXML
    private Button addButton;

    @FXML
    private TextField id_firmyTextField;
    @FXML
    private TextField NIPTextField;
    @FXML
    private TextField REGONTextField;
    @FXML
    private TextField numerKRSTextField;
    @FXML
    private TextField nazwa_firmyTextField;
    @FXML
    private TextField emailTextField;
    @FXML
    private TextField nr_telefonuTextField;
    @FXML
    private TextField nr_ulicyTextField;
    @FXML
    private TextField nr_budynkuTextField;
    @FXML
    private TextField kod_pocztowyTextField;
    @FXML
    private TextField nr_miejscowosciTextField;

    @FXML
    public void addFirm(final ActionEvent event) {
        // TODO: adding firm to database using text fields
    }

    @FXML
    public void initialize() {
        //TODO: fill tableview
    }
}
