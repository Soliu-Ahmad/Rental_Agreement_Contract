import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const RentalAgreementModule = buildModule("SwapTokenModule", (m) => {
  const mpxToken = m.contract("MPXToken", ["0x0D33Ee49A31FfB9B579dF213370f634e4a8BbEEd"]);

  const rentalAgreement = m.contract("RentalAgreement", [mpxToken]);

  return { rentalAgreement };
});

export default RentalAgreementModule;