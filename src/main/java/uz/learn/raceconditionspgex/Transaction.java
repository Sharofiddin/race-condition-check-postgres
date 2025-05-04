package uz.learn.raceconditionspgex;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;

@Table("transaction")
public record Transaction(
    @Id 
    @Column("external_id")
    String externalId,
    @Column("from_wallet")
    String fromWallet,
    @Column("to_wallet")
    String toWallet,
    BigDecimal amount
) {}