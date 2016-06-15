package controllers;

import database.Database;
import database.datatypes.Firma;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;

import java.sql.SQLException;
import java.sql.Statement;

public class FirmsController {
    @FXML
    private TableView<Firma> tableView;
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
    public void addFirm(final ActionEvent event)
    {
        final String query=
                "INSERT INTO firma VALUES("+id_firmyTextField.getText()+", '"+
                        NIPTextField.getText()+"', '"+REGONTextField.getText()+"', '"+
                        numerKRSTextField.getText()+"', '"+nazwa_firmyTextField.getText()+"', '"+
                        emailTextField.getText()+"', '"+nr_telefonuTextField.getText()+"', '"+
                        nr_ulicyTextField.getText()+"', '"+nr_budynkuTextField.getText()+"', '"+
                        kod_pocztowyTextField.getText()+"', "+nr_miejscowosciTextField.getText()+")";

        try(Statement stmt=Database.instance.connection.createStatement())
        {
            stmt.executeUpdate(query);
        }catch(final SQLException e)
        {
            e.printStackTrace();
        }
    }

    @FXML
    public void initialize() {
        Database.instance.getFirmsTable(tableView);
    }
}
