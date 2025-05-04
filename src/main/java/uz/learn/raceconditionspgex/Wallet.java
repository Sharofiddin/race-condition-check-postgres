package uz.learn.raceconditionspgex;

import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigDecimal;

@Table("wallet")
public record Wallet(
    @Id String walletid,
    BigDecimal deposit
) {}