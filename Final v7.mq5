//+---------------------------------------------+
//|       Technic informatique Final v7         |
//|       Auteur : Technic' informatique        |
//+---------------------------------------------+
#property copyright "© 2025, Technic informatique"
#property version   "7.0"
#property strict
#include <Trade\Trade.mqh>
CTrade trade;
//+======================================+
//|           SECTION TRADING            |
//+======================================+
//+-----------+
//| Fonctions |
//+-----------+
void ManagePendingOrders();
void ManageTrailingStopLoss();
void PlaceBuyOrder();
void PlaceSellOrder();
void SetInitialStopLoss();
void SetInitialTakeProfit();
bool CanPlaceAnotherBuy();
bool CanPlaceAnotherSell();
void GetAllBuySidePrices(double &pricesBuySide[]);
void GetAllSellSidePrices(double &pricesSellSide[]);
int CountPositions(ENUM_POSITION_TYPE type);
int CountPendingOrders(ENUM_ORDER_TYPE type);
void CheckCloseOnCandleIfProfit();
bool CanAffordNextTrade(bool isBuy);
bool CheckLicense();
double GetAdjustedAsk();
double GetAdjustedBid();
bool IsValidTradingTime(ENUM_TIMEFRAMES timeframe, bool isBuy);
double GetAccumulatedSwapCost(ulong ticket);
double EstimateBrokerFees(double volume, ENUM_POSITION_TYPE type);
double GetRealBrokerFees(double volume, ENUM_POSITION_TYPE type);
double GetAverageCommissionFromHistory();
double CalculateTPWithFeeCompensation(double openPrice, double baseTpPips, double volume, ENUM_POSITION_TYPE type);
void DeleteAllPendingOrdersAfterClose();
bool CanPlaceHelperTrade(ENUM_POSITION_TYPE type);
double CalculateTradeVolume(bool isBuy, int gridLevel);
double CalculateTotalPipsWithCosts(ENUM_POSITION_TYPE type);
void CheckCumulativeSingleTP();
void CheckCumulativeMultiTP();
void CheckCumulativePosTP();
void CheckLadderProfitTP();
void CheckWaveRidingTP();
void CheckVixReversionTP();
void CheckMomentumBurstTP();
void CheckScalpAccumulatorTP();
void CheckVixOscillationMasterTP();
void CheckProfitCompoundingTP();
void CheckBreakoutSurferTP();
struct PartialTradeInfo;
void ManagePartialClosureSystem();
bool CheckMainTradeTP(PartialTradeInfo &tradeInfo, ENUM_POSITION_TYPE type);
bool CheckCombinedTP(PartialTradeInfo &tradeInfo, ENUM_POSITION_TYPE type);
bool IsPriceWithinBuyLimits(double price);
bool IsPriceWithinSellLimits(double price);
bool CanPlaceTradeWithFullValidation(ENUM_POSITION_TYPE type, double proposedPrice = 0.0);
void CloseAllTrades(ENUM_POSITION_TYPE type);
void AddToPartialSystem(ulong ticket, double volume, double openPrice, ENUM_POSITION_TYPE type);
void PlaceHelperTrade(PartialTradeInfo &tradeInfo, ENUM_POSITION_TYPE type);
double CalculateOptimalUnitSize(double totalVolume);
double CalculateBreakEvenLongSymbol(string symbol);
double CalculateBreakEvenShortSymbol(string symbol);
void GetDynamicPanelPositionForPanel(int index, int &posX, int &posY);
void UpdateTextLineEx(const string name, const int x, const int y, const color clr, const int size, const string font, const string text);
string FormatTimeLeft(int seconds, ENUM_TIMEFRAMES timeframe, int startHour, int startMinute);
void UpdatePanelForSymbol(string symWithMagic, int index);
void DrawVirtualTP();
void InitializeGraphics();
void CleanupGraphics();
void UpdateGraphics();
input group "=== Paramètres Affichage ==="
input bool   EnableGraphics                      = true;           // Activer/Désactiver l'affichage graphique
input double Ratio                               = 1.0;            // 1.0 = base ; 0.8 = -20% ; 1.2 = +20%
input int    DisplayCount                        = 1;              // Nombre total de panneaux à afficher
input int    LongeurMagic                        = 3;              // Longeur du n° magique à afficher
input string DisplaySymbols                      = "GOOG111";      // Symbole+N°Magique à afficher (actif111,actif222)
input int    MagicNumber                         = 111;            // Numéro magique du robot
input string WebRequest_A_Rajouter               = "===== http://wyptekx.cluster029.hosting.ovh.net =====";
input color  ChartBackgroundColor                = clrGainsboro;   // Couleur de fond du graphique
input color  ChartGridColor                      = clrNONE;        // Couleur de la grille
input color  CandleBullColor                     = clrDodgerBlue;  // Couleur bougies haussières
input color  CandleBearColor                     = clrOrangeRed;   // Couleur bougies baissières
input color  EnvironnementColor                  = clrOrangeRed;   // Couleur du texte de l'environnement
input color  PanelBackgroundColor                = clrLightBlue;   // Couleur de fond du panneau
input int    PanelWidth                          = 405;            // Largeur du panneau
input int    PanelHeight                         = 455;            // Hauteur du panneau
input int    OffsetX                             = 80;             // Décalage vers la droite du panneau
input int    OffsetY                             = 20;             // Décalage vers le bas du panneau
input color  Line1Color                          = clrOrangeRed;   // Couleur ligne Titre
input int    Line1Size                           = 20;             // Taille ligne Titre
input color  Line2Color                          = clrDarkViolet;  // Couleur ligne Actif/N° magique
input int    Line2Size                           = 14;             // Taille ligne Actif/N° magique
input color  Line7Color                          = clrDarkViolet;  // Couleur ligne Heure broker/Spread
input int    Line7Size                           = 14;             // Taille ligne Heure broker/Spread
input color  Line3Color                          = clrDeepSkyBlue; // Couleur ligne Nombre d'achats
input int    Line3Size                           = 14;             // Taille ligne Nombre d'achats
input color  Line3_1Color                        = clrDeepSkyBlue; // Couleur ligne Ajout/Modif. ordre d'achat dans
input int    Line3_1Size                         = 14;             // Taille ligne Ajout/Modif. ordre d'achat dans
input color  Line6Color                          = clrDeepSkyBlue; // Couleur ligne Solde nul à la baisse
input int    Line6Size                           = 14;             // Taille ligne Solde nul à la baisse
input color  Line4Color                          = clrLightSalmon; // Couleur ligne Nombre de ventes
input int    Line4Size                           = 14;             // Taille ligne Nombre de ventes
input color  Line4_1Color                        = clrLightSalmon; // Couleur ligne Ajout/Modif. ordre de vente dans
input int    Line4_1Size                         = 14;             // Taille ligne Ajout/Modif. ordre de vente dans
input color  Line5Color                          = clrLightSalmon; // Couleur ligne Solde nul à la hausse
input int    Line5Size                           = 14;             // Taille ligne Solde nul à la hausse
input group "=== Compensation des Frais ==="
input bool   EnableBrokerFeeCompensation           = true;           // Compenser les frais de broker dans les TP
input bool   AutoDetectBrokerFees                 = true;           // Récupérer automatiquement les frais depuis le broker
input double EstimatedCommissionRate               = 0.0005;         // Taux de commission estimé (si auto-détection désactivée)
input double EstimatedSwapRate                     = 0.0002;         // Taux de swap estimé (si auto-détection désactivée)
input group "=== Paramètres Achats ==="
input ENUM_TIMEFRAMES TimeframeBuy               = PERIOD_M1;      // Sélecteur de période
input int    StartHourBuy                        = 0;              // Heure de départ (0-23)
input int    StartMinuteBuy                      = 0;              // Minute de départ (0-59)
input bool   UseGridVolumeBuy                    = false;          // True=Grid (BaseVolume), False=Fixe (LotSize)
input double LotSizeBuy                          = 0.1;            // Lots fixes pour tous les ordres
input double BaseVolumeBuy                       = 0.1;            // Lots pour démarrer la grille
input double MaxBaseVolumeBuy                    = 0.5;            // Lots maximum pour la grille
input double GridMultiplierBuy                   = 2.0;            // Multiplicateur de lots pour la grille
input int    MaxBuyTrades                        = 100;            // Nombre de trades maximum
input double PrixMinimumAchat                    = 0.0;            // Prix minimum pour les achats (0 = aucune limite)
input double PrixMaximumAchat                    = 0.0;            // Prix maximum pour les achats (0 = aucune limite)
input int    DistanceOrderBuy                    = 100;            // Distance entre le prix et les ordres
input int    TrailingDistanceOrderBuy            = 200;            // Distance de réajustement des ordres
input int    DistanceMinEntre2TradesBuy          = 300;            // Distance minimum entre 2 trades
input int    InitialStopLossBuy                  = 0;              // SL (0 = aucun SL)
input int    InitialTakeProfitBuy                = 200;            // TP (0 = aucun TP)
input int    TrailingStartBuy                    = 1000000;        // Trailing Start
input int    TrailingStopLossBuy                 = 1000000;        // Trailing Distance
enum         BuyTrailingMode { BUY_MODE_NONE     = 0, BUY_CUMUL_SINGLE = 1, BUY_CUMUL_MULTI = 2, BUY_CLOSE_CANDLE = 3, BUY_CUMUL_POS = 4, BUY_PARTIAL_CLOSURE = 5, BUY_LADDER_PROFIT = 6, BUY_WAVE_RIDING = 7, BUY_VIX_REVERSION = 8, BUY_MOMENTUM_BURST = 9, BUY_SCALP_ACCUMULATOR = 10, BUY_VIX_OSCILLATION_MASTER = 11, BUY_PROFIT_COMPOUNDING = 12, BUY_BREAKOUT_SURFER = 13 };
input        BuyTrailingMode BuyMode             = BUY_MODE_NONE;  // Mode de trailing
input double CumulPosReductionFactorBuy          = 0.1;            // CUMUL_POS: Facteur de réduction TP par position (0.1 = -10% par position)
input double CumulPosMinTPPercentBuy             = 0.6;            // CUMUL_POS: TP minimum (% du TP initial)
input bool InverserOrdresBuy                     = false;          // Inverser les ordres (BuyStop en BuyLimit)
input bool NouveauxOrdresAPrixPlusAvantageuxBuy  = true;           // Nouveaux ordres à prix plus avantageux
input group "=== Paramètres Ventes ==="
input ENUM_TIMEFRAMES TimeframeSell              = PERIOD_M1;      // Sélecteur de période
input int    StartHourSell                       = 0;              // Heure de départ (0-23)
input int    StartMinuteSell                     = 0;              // Minute de départ (0-59) 
input bool   UseGridVolumeSell                   = false;          // True=Grid (BaseVolume), False=Fixe (LotSize)
input double LotSizeSell                         = 0.1;            // Lots fixes pour tous les ordres
input double BaseVolumeSell                      = 0.1;            // Lots pour démarrer la grille
input double MaxBaseVolumeSell                   = 0.5;            // Lots maximum pour la grille  
input double GridMultiplierSell                  = 2.0;            // Multiplicateur de lots pour la grille
input int    MaxSellTrades                       = 100;            // Nombre de trades maximum
input double PrixMinimumVente                    = 0.0;            // Prix minimum pour les ventes (0 = aucune limite)
input double PrixMaximumVente                    = 0.0;            // Prix maximum pour les ventes (0 = aucune limite)
input int    DistanceOrderSell                   = 100;            // Distance entre le prix et les ordres
input int    TrailingDistanceOrderSell           = 200;            // Distance de réajustement des ordres
input int    DistanceMinEntre2TradesSell         = 300;            // Distance minimum entre 2 trades
input int    InitialStopLossSell                 = 0;              // SL (0 = aucun SL)
input int    InitialTakeProfitSell               = 200;            // TP (0 = aucun TP)
input int    TrailingStartSell                   = 1000000;        // Trailing Start
input int    TrailingStopLossSell                = 1000000;        // Trailing Distance
enum         SellTrailingMode { SELL_MODE_NONE   = 0, SELL_CUMUL_SINGLE = 1, SELL_CUMUL_MULTI = 2, SELL_CLOSE_CANDLE = 3, SELL_CUMUL_POS = 4, SELL_PARTIAL_CLOSURE = 5, SELL_LADDER_PROFIT = 6, SELL_WAVE_RIDING = 7, SELL_VIX_REVERSION = 8, SELL_MOMENTUM_BURST = 9, SELL_SCALP_ACCUMULATOR = 10, SELL_VIX_OSCILLATION_MASTER = 11, SELL_PROFIT_COMPOUNDING = 12, SELL_BREAKOUT_SURFER = 13 };
input        SellTrailingMode SellMode           = SELL_MODE_NONE; // Mode de trailing
input double CumulPosReductionFactorSell         = 0.1;            // CUMUL_POS: Facteur de réduction TP par position (0.1 = -10% par position)
input double CumulPosMinTPPercentSell            = 0.6;            // CUMUL_POS: TP minimum (% du TP initial)
input bool InverserOrdresSell                    = false;          // Inverser les ordres (SellStop en SellLimit)
input bool NouveauxOrdresAPrixPlusAvantageuxSell = true;           // Nouveaux ordres à prix plus avantageux
input group "=== Paramètres Backtests ==="
input bool   BackTestMode                        = true;           // Mode BackTest
input double MaxAccountBalance                   = 1000.0;         // Solde maximum du compte (€)
input double BackTestStopThreshold               = -1000.0;        // Arrêt du BackTest après perte en €
input double PointZero                           = 0.0;            // Point zéro pour calcul pertes (prix de référence)
input int    BackTestSpread                      = 10;             // Spread personnalisé
bool         PrematureStop                       = false;
double       g_initialBalance                    = 0.0;
bool         gridResetBuy                        = false;
bool         gridResetSell                       = false;
string       LicenseFileURL                      = "http://wyptekx.cluster029.hosting.ovh.net/Trading/Licences/TiAkTrade47Final.txt";
bool CanAffordNextTrade(bool isBuy)
{
   double availableCapital;
   if(BackTestMode)
   {
      availableCapital = MaxAccountBalance;
   }
   else
   {
      availableCapital = MathAbs(BackTestStopThreshold);
   }
   double effectivePointZero = (PointZero <= 0) ? 0.01 : PointZero;
   if(availableCapital <= 0) return true;
   double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   if(contractSize <= 0) contractSize = 1.0;
   if(isBuy)
   {
      int currentTrades = CountPositions(POSITION_TYPE_BUY);
      double currentPrice = GetAdjustedAsk();
      double nextLot = CalculateTradeVolume(true, currentTrades);
      double totalCostIfZero = 0.0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double volume = PositionGetDouble(POSITION_VOLUME);
               double cost = volume * contractSize * (openPrice - effectivePointZero);
               totalCostIfZero += cost;
            }
         }
      }
      double newTradeCost = nextLot * contractSize * (currentPrice - effectivePointZero);
      totalCostIfZero += newTradeCost;
      bool canAfford = (totalCostIfZero <= availableCapital);
      return canAfford;
   }
   else
   {
      int currentTrades = CountPositions(POSITION_TYPE_SELL);
      double currentPrice = GetAdjustedBid();
      double nextLot = CalculateTradeVolume(false, currentTrades);
      double totalCostIfZero = 0.0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double volume = PositionGetDouble(POSITION_VOLUME);
               double cost = volume * contractSize * (effectivePointZero - openPrice);
               totalCostIfZero += cost;
            }
         }
      }
      double newTradeCost = nextLot * contractSize * (effectivePointZero - currentPrice);
      totalCostIfZero += newTradeCost;
      bool canAfford = (totalCostIfZero <= availableCapital);
      return canAfford;
   }
}

bool CheckLicense()
  {
   if(MQLInfoInteger(MQL_TESTER))
      return true;
   long accountNumber = AccountInfoInteger(ACCOUNT_LOGIN);
   char result[];
   char postData[];
   string headers;
   int httpCode = WebRequest("GET", LicenseFileURL, "", 5000, postData, result, headers);
   if(httpCode == 200)
     {
      string content = CharArrayToString(result);
      StringReplace(content, "\r", "\n");
      while(StringLen(content) > 0)
        {
         int pos = StringFind(content, "\n", 0);
         string line;
         if(pos >= 0)
           {
            line    = StringSubstr(content, 0, pos);
            content = StringSubstr(content, pos + 1);
           }
         else
           {
            line    = content;
            content = "";
           }
         StringTrimLeft(line);
         StringTrimRight(line);
         if(StringLen(line) == 0)
            continue;
         int posComment = StringFind(line, "#", 0);
         if(posComment != -1)
           {
            line = StringSubstr(line, 0, posComment);
            StringTrimLeft(line);
            StringTrimRight(line);
           }
         if(line == IntegerToString(accountNumber))
           {
            Print("Licence OK pour ce compte ", accountNumber);
            return true;
           }
        }
      Print("Licence refusée pour ce compte ", accountNumber, " non listé");
      return false;
     }
   Print("Erreur WebRequest. Code HTTP=", httpCode);
   return false;
  }

void ManageTrailingStopLoss()
{
   if(BuyMode == BUY_MODE_NONE || SellMode == SELL_MODE_NONE)
   {
      double bid = GetAdjustedBid();
      double ask = GetAdjustedAsk();
      double point = _Point;
      for(int i = PositionsTotal()-1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
               ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double stopLoss = PositionGetDouble(POSITION_SL);
               double currentPrice = (type == POSITION_TYPE_BUY ? bid : ask);
               double profitPips = (type == POSITION_TYPE_BUY) ? (currentPrice - openPrice)/point
                                 : (openPrice - currentPrice)/point;
               if(type == POSITION_TYPE_BUY && BuyMode == BUY_MODE_NONE)
               {
                  if(profitPips >= TrailingStartBuy)
                  {
                     double trailingStopDistance = TrailingStopLossBuy * point;
                     double newSL = NormalizeDouble(currentPrice - trailingStopDistance, _Digits);
                     if(newSL > stopLoss || stopLoss <= 0.0000001)
                        if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                           Print("Erreur modification SL BUY : ", trade.ResultRetcode());
                  }
               }
               else if(type == POSITION_TYPE_SELL && SellMode == SELL_MODE_NONE)
               {
                  if(profitPips >= TrailingStartSell)
                  {
                     double trailingStopDistance = TrailingStopLossSell * point;
                     double newSL = NormalizeDouble(currentPrice + trailingStopDistance, _Digits);
                     if(newSL < stopLoss || stopLoss <= 0.0000001)
                        if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                           Print("Erreur modification SL SELL : ", trade.ResultRetcode());
                  }
               }
            }
         }
      }
   }
   if(BuyMode == BUY_CUMUL_SINGLE || BuyMode == BUY_CUMUL_MULTI)
   {
      double totalPipsBuy = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
      if(totalPipsBuy >= TrailingStartBuy)
      {
         for(int i = PositionsTotal()-1; i >= 0; i--)
         {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
               if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                  PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               {
                  double bid = GetAdjustedBid();
                  double point = _Point;
                  double stopLoss = PositionGetDouble(POSITION_SL);
                  double trailingStopDistance = TrailingStopLossBuy * point;
                  double newSL = NormalizeDouble(bid - trailingStopDistance, _Digits);
                  if(newSL > stopLoss || stopLoss <= 0.0000001)
                     if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                        Print("Erreur modification SL BUY cumulatif : ", trade.ResultRetcode());
               }
            }
         }
      }
   }
   if(SellMode == SELL_CUMUL_SINGLE || SellMode == SELL_CUMUL_MULTI)
   {
      double totalPipsSell = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
      if(totalPipsSell >= TrailingStartSell)
      {
         for(int i = PositionsTotal()-1; i >= 0; i--)
         {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
               if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                  PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
               {
                  double ask = GetAdjustedAsk();
                  double point = _Point;
                  double stopLoss = PositionGetDouble(POSITION_SL);
                  double trailingStopDistance = TrailingStopLossSell * point;
                  double newSL = NormalizeDouble(ask + trailingStopDistance, _Digits);
                  if(newSL < stopLoss || stopLoss <= 0.0000001)
                     if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                        Print("Erreur modification SL SELL cumulatif : ", trade.ResultRetcode());
               }
            }
         }
      }
   }
   if(BuyMode == BUY_CUMUL_POS)
   {
      double totalPipsBuy = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
      if(totalPipsBuy >= TrailingStartBuy)
      {
         for(int i = PositionsTotal()-1; i >= 0; i--)
         {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
               if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                  PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               {
                  double bid = GetAdjustedBid();
                  double point = _Point;
                  double stopLoss = PositionGetDouble(POSITION_SL);
                  double trailingStopDistance = TrailingStopLossBuy * point;
                  double newSL = NormalizeDouble(bid - trailingStopDistance, _Digits);
                  if(newSL > stopLoss || stopLoss <= 0.0000001)
                     if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                        Print("Erreur modification SL BUY CUMUL_POS : ", trade.ResultRetcode());
               }
            }
         }
      }
   }
   if(SellMode == SELL_CUMUL_POS)
   {
      double totalPipsSell = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
      if(totalPipsSell >= TrailingStartSell)
      {
         for(int i = PositionsTotal()-1; i >= 0; i--)
         {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
               if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                  PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
               {
                  double ask = GetAdjustedAsk();
                  double point = _Point;
                  double stopLoss = PositionGetDouble(POSITION_SL);
                  double trailingStopDistance = TrailingStopLossSell * point;
                  double newSL = NormalizeDouble(ask + trailingStopDistance, _Digits);
                  if(newSL < stopLoss || stopLoss <= 0.0000001)
                     if(!trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP)))
                        Print("Erreur modification SL SELL CUMUL_POS : ", trade.ResultRetcode());
               }
            }
         }
      }
   }
}

void ManagePendingOrders()
{
   double point = _Point;
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(!OrderSelect(ticket))
         continue;
      if(OrderGetInteger(ORDER_MAGIC) != MagicNumber)
         continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol)
         continue;
      ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      double openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      if(otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_BUY_LIMIT)
      {
         if(!InverserOrdresBuy && otype == ORDER_TYPE_BUY_STOP)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + DistanceOrderBuy * point, _Digits);
            if(!IsPriceWithinBuyLimits(desiredPrice))
            {
               Print("⚠️ Modification ordre BUY_STOP ignorée - Prix (", DoubleToString(desiredPrice, _Digits), 
                     ") hors limites [", DoubleToString(PrixMinimumAchat, _Digits), " - ", 
                     DoubleToString(PrixMaximumAchat, _Digits), "]");
               continue;
            }
            
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderBuy * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif BUY_STOP : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxBuy)
            {
               double lowestActiveBuy = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(lowestActiveBuy < 0 || posPrice < lowestActiveBuy)
                           lowestActiveBuy = posPrice;
                     }
                  }
               }
               if(lowestActiveBuy > 0)
               {
                  double threshold = lowestActiveBuy - (DistanceMinEntre2TradesBuy + DistanceOrderBuy) * point;
                  if(openPrice > threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression BUY_STOP : ", trade.ResultRetcode());
                  }
               }
            }
         }
         else if(InverserOrdresBuy && otype == ORDER_TYPE_BUY_LIMIT)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - DistanceOrderBuy * point, _Digits);
            if(!IsPriceWithinBuyLimits(desiredPrice))
            {
               Print("⚠️ Modification ordre BUY_LIMIT ignorée - Prix (", DoubleToString(desiredPrice, _Digits), 
                     ") hors limites [", DoubleToString(PrixMinimumAchat, _Digits), " - ", 
                     DoubleToString(PrixMaximumAchat, _Digits), "]");
               continue;
            }
            
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderBuy * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif BUY_LIMIT : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxBuy)
            {
               double lowestActiveBuy = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(lowestActiveBuy < 0 || posPrice < lowestActiveBuy)
                           lowestActiveBuy = posPrice;
                     }
                  }
               }
               if(lowestActiveBuy > 0)
               {
                  double threshold = lowestActiveBuy - (DistanceMinEntre2TradesBuy + DistanceOrderBuy) * point;
                  if(openPrice > threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression BUY_LIMIT : ", trade.ResultRetcode());
                  }
               }
            }
         }
      }
      
      if(otype == ORDER_TYPE_SELL_STOP || otype == ORDER_TYPE_SELL_LIMIT)
      {
         if(!InverserOrdresSell && otype == ORDER_TYPE_SELL_STOP)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - DistanceOrderSell * point, _Digits);
            if(!IsPriceWithinSellLimits(desiredPrice))
            {
               Print("⚠️ Modification ordre SELL_STOP ignorée - Prix (", DoubleToString(desiredPrice, _Digits), 
                     ") hors limites [", DoubleToString(PrixMinimumVente, _Digits), " - ", 
                     DoubleToString(PrixMaximumVente, _Digits), "]");
               continue;
            }
            
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderSell * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif SELL_STOP : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxSell)
            {
               double highestActiveSell = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(highestActiveSell < 0 || posPrice > highestActiveSell)
                           highestActiveSell = posPrice;
                     }
                  }
               }
               if(highestActiveSell > 0)
               {
                  double threshold = highestActiveSell + (DistanceMinEntre2TradesSell + DistanceOrderSell) * point;
                  if(openPrice < threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression SELL_STOP : ", trade.ResultRetcode());
                  }
               }
            }
         }
         else if(InverserOrdresSell && otype == ORDER_TYPE_SELL_LIMIT)
         {
            double desiredPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + DistanceOrderSell * point, _Digits);
            if(!IsPriceWithinSellLimits(desiredPrice))
            {
               Print("⚠️ Modification ordre SELL_LIMIT ignorée - Prix (", DoubleToString(desiredPrice, _Digits), 
                     ") hors limites [", DoubleToString(PrixMinimumVente, _Digits), " - ", 
                     DoubleToString(PrixMaximumVente, _Digits), "]");
               continue;
            }
            
            double diff = MathAbs(openPrice - desiredPrice);
            if(diff > TrailingDistanceOrderSell * point)
            {
               trade.SetExpertMagicNumber(MagicNumber);
               if(!trade.OrderModify(ticket, desiredPrice, 0.0, 0.0, ORDER_TIME_GTC, 0, 0))
                  Print("Erreur modif SELL_LIMIT : ", trade.ResultRetcode());
            }
            if(NouveauxOrdresAPrixPlusAvantageuxSell)
            {
               double highestActiveSell = -1;
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong tick = PositionGetTicket(j);
                  if(PositionSelectByTicket(tick))
                  {
                     if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
                        PositionGetString(POSITION_SYMBOL)==_Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                     {
                        double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                        if(highestActiveSell < 0 || posPrice > highestActiveSell)
                           highestActiveSell = posPrice;
                     }
                  }
               }
               if(highestActiveSell > 0)
               {
                  double threshold = highestActiveSell + (DistanceMinEntre2TradesSell + DistanceOrderSell) * point;
                  if(openPrice < threshold)
                  {
                     if(!trade.OrderDelete(ticket))
                        Print("Erreur suppression SELL_LIMIT : ", trade.ResultRetcode());
                  }
               }
            }
         }
      }
   }
}

void PlaceBuyOrder()
{
   // Validation complète AVANT de calculer quoi que ce soit
   if(!CanPlaceTradeWithFullValidation(POSITION_TYPE_BUY))
   {
      return; // Validation échouée, sortie immédiate
   }
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double point = _Point;
   trade.SetExpertMagicNumber(MagicNumber);
   int gridBuy = CountPositions(POSITION_TYPE_BUY) + CountPendingOrders((!InverserOrdresBuy) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_LIMIT);
   double lotBuy = CalculateTradeVolume(true, gridBuy);
   bool orderSuccess = false;
   double orderPrice = 0.0;
   if(!InverserOrdresBuy)
   {
      orderPrice = NormalizeDouble(ask + DistanceOrderBuy * point, _Digits);
      // Double validation du prix (déjà fait dans CanPlaceTradeWithFullValidation, mais on garde pour sécurité)
      if(!IsPriceWithinBuyLimits(orderPrice))
      {
         Print("❌ Ordre BUY non placé - Prix (", DoubleToString(orderPrice, _Digits), 
               ") hors limites [", DoubleToString(PrixMinimumAchat, _Digits), " - ", 
               DoubleToString(PrixMaximumAchat, _Digits), "]");
         return;
      }
      
      orderSuccess = trade.BuyStop(lotBuy, orderPrice, _Symbol);
      if(!orderSuccess)
         Print("Erreur BuyStop (mode normal) : ", trade.ResultRetcode());
   }
   else
   {
      orderPrice = NormalizeDouble(ask - DistanceOrderBuy * point, _Digits);
      // Double validation du prix (déjà fait dans CanPlaceTradeWithFullValidation, mais on garde pour sécurité)
      if(!IsPriceWithinBuyLimits(orderPrice))
      {
         Print("❌ Ordre BUY non placé - Prix (", DoubleToString(orderPrice, _Digits), 
               ") hors limites [", DoubleToString(PrixMinimumAchat, _Digits), " - ", 
               DoubleToString(PrixMaximumAchat, _Digits), "]");
         return;
      }
      
      orderSuccess = trade.BuyLimit(lotBuy, orderPrice, _Symbol);
      if(!orderSuccess)
         Print("Erreur BuyLimit (mode inversé) : ", trade.ResultRetcode());
   }
   
   if(orderSuccess && BuyMode == BUY_PARTIAL_CLOSURE)
   {
      ulong ticket = trade.ResultOrder();
      AddToPartialSystem(ticket, lotBuy, orderPrice, POSITION_TYPE_BUY);
      string mode = UseGridVolumeBuy ? "GRID" : "FIXE";
      Print("🔄 Trade BUY ", ticket, " ajouté au système partiel (", lotBuy, " lots - Mode ", mode, ")");
   }
}

void PlaceSellOrder()
{
   // Validation complète AVANT de calculer quoi que ce soit
   if(!CanPlaceTradeWithFullValidation(POSITION_TYPE_SELL))
   {
      return; // Validation échouée, sortie immédiate
   }
   
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = _Point;
   trade.SetExpertMagicNumber(MagicNumber);
   int gridSell = CountPositions(POSITION_TYPE_SELL) + CountPendingOrders((!InverserOrdresSell) ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT);
   double lotSell = CalculateTradeVolume(false, gridSell);
   bool orderSuccess = false;
   double orderPrice = 0.0;
   if(!InverserOrdresSell)
   {
      orderPrice = NormalizeDouble(bid - DistanceOrderSell * point, _Digits);
      // Double validation du prix (déjà fait dans CanPlaceTradeWithFullValidation, mais on garde pour sécurité)
      if(!IsPriceWithinSellLimits(orderPrice))
      {
         Print("❌ Ordre SELL non placé - Prix (", DoubleToString(orderPrice, _Digits), 
               ") hors limites [", DoubleToString(PrixMinimumVente, _Digits), " - ", 
               DoubleToString(PrixMaximumVente, _Digits), "]");
         return;
      }
      
      orderSuccess = trade.SellStop(lotSell, orderPrice, _Symbol);
      if(!orderSuccess)
         Print("Erreur SellStop (mode normal) : ", trade.ResultRetcode());
   }
   else
   {
      orderPrice = NormalizeDouble(bid + DistanceOrderSell * point, _Digits);
      // Double validation du prix (déjà fait dans CanPlaceTradeWithFullValidation, mais on garde pour sécurité)
      if(!IsPriceWithinSellLimits(orderPrice))
      {
         Print("❌ Ordre SELL non placé - Prix (", DoubleToString(orderPrice, _Digits), 
               ") hors limites [", DoubleToString(PrixMinimumVente, _Digits), " - ", 
               DoubleToString(PrixMaximumVente, _Digits), "]");
         return;
      }
      
      orderSuccess = trade.SellLimit(lotSell, orderPrice, _Symbol);
      if(!orderSuccess)
         Print("Erreur SellLimit (mode inversé) : ", trade.ResultRetcode());
   }
   
   if(orderSuccess && SellMode == SELL_PARTIAL_CLOSURE)
   {
      ulong ticket = trade.ResultOrder();
      AddToPartialSystem(ticket, lotSell, orderPrice, POSITION_TYPE_SELL);
      string mode = UseGridVolumeSell ? "GRID" : "FIXE";
      Print("🔄 Trade SELL ", ticket, " ajouté au système partiel (", lotSell, " lots - Mode ", mode, ")");
   }
}

void SetInitialTakeProfit()
  {
   double point = _Point;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
           {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double tp = PositionGetDouble(POSITION_TP);
            if(tp == 0.0)
              {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double volume = PositionGetDouble(POSITION_VOLUME);
               double newTP;
               if(type == POSITION_TYPE_BUY)
                 {
                  if(InitialTakeProfitBuy != 0 && (BuyMode == BUY_MODE_NONE || BuyMode == BUY_PARTIAL_CLOSURE))
                  {
                     if(EnableBrokerFeeCompensation)
                     {
                        newTP = CalculateTPWithFeeCompensation(openPrice, InitialTakeProfitBuy, volume, type);
                     }
                     else
                     {
                        newTP = NormalizeDouble(openPrice + (InitialTakeProfitBuy * point), _Digits);
                     }
                  }
                  else
                     continue;
                 }
               else
                 {
                  if(InitialTakeProfitSell != 0 && (SellMode == SELL_MODE_NONE || SellMode == SELL_PARTIAL_CLOSURE))
                  {
                     if(EnableBrokerFeeCompensation)
                     {
                        newTP = CalculateTPWithFeeCompensation(openPrice, InitialTakeProfitSell, volume, type);
                     }
                     else
                     {
                        newTP = NormalizeDouble(openPrice - (InitialTakeProfitSell * point), _Digits);
                     }
                  }
                  else
                     continue;
                 }
               trade.PositionModify(ticket, PositionGetDouble(POSITION_SL), newTP);
              }
           }
        }
     }
  }

void SetInitialStopLoss()
  {
   double point = _Point;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol)
           {
            double sl = PositionGetDouble(POSITION_SL);
            if(sl == 0.0)
              {
               ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double newSL;
               if(type == POSITION_TYPE_BUY)
                 {
                  if(InitialStopLossBuy != 0)
                     newSL = NormalizeDouble(openPrice - (InitialStopLossBuy * point), _Digits);
                  else
                     continue;
                 }
               else
                 {
                  if(InitialStopLossSell != 0)
                     newSL = NormalizeDouble(openPrice + (InitialStopLossSell * point), _Digits);
                  else
                     continue;
                 }
               trade.PositionModify(ticket, newSL, PositionGetDouble(POSITION_TP));
              }
           }
        }
     }
  }

bool CanPlaceAnotherBuy()
  {
   double prospectivePrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + DistanceOrderBuy * _Point;
   double allPrices[];
   GetAllBuySidePrices(allPrices);
   int count = ArraySize(allPrices);
   if(count == 0)
      return true;
   if(NouveauxOrdresAPrixPlusAvantageuxBuy)
     {
      double lowestBuy = allPrices[0];
      for(int i = 1; i < count; i++)
         lowestBuy = MathMin(lowestBuy, allPrices[i]);
      double minPriceAllowed = lowestBuy - DistanceMinEntre2TradesBuy * _Point;
      if(prospectivePrice > minPriceAllowed)
         return false;
     }
   return true;
  }

bool CanPlaceAnotherSell()
  {
   double prospectivePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID) - DistanceOrderSell * _Point;
   double allPrices[];
   GetAllSellSidePrices(allPrices);
   int count = ArraySize(allPrices);
   if(count == 0)
      return true;
   if(NouveauxOrdresAPrixPlusAvantageuxSell)
     {
      double highestSell = allPrices[0];
      for(int i = 1; i < count; i++)
         highestSell = MathMax(highestSell, allPrices[i]);
      double minPriceAllowed = highestSell + DistanceMinEntre2TradesSell * _Point;
      if(prospectivePrice < minPriceAllowed)
         return false;
     }
   return true;
  }

void GetAllBuySidePrices(double &pricesBuySide[])
  {
   ArrayResize(pricesBuySide, 0);
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            int n = ArraySize(pricesBuySide);
            ArrayResize(pricesBuySide, n+1);
            pricesBuySide[n] = openPrice;
           }
        }
     }
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber &&
            OrderGetString(ORDER_SYMBOL)==_Symbol)
           {
            ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if(otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_BUY_LIMIT)
              {
               double openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
               int n = ArraySize(pricesBuySide);
               ArrayResize(pricesBuySide, n+1);
               pricesBuySide[n] = openPrice;
              }
           }
        }
     }
  }

void GetAllSellSidePrices(double &pricesSellSide[])
  {
   ArrayResize(pricesSellSide, 0);
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            int n = ArraySize(pricesSellSide);
            ArrayResize(pricesSellSide, n+1);
            pricesSellSide[n] = openPrice;
           }
        }
     }
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber &&
            OrderGetString(ORDER_SYMBOL)==_Symbol)
           {
            ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if(otype == ORDER_TYPE_SELL_STOP || otype == ORDER_TYPE_SELL_LIMIT)
              {
               double openPrice = OrderGetDouble(ORDER_PRICE_OPEN);
               int n = ArraySize(pricesSellSide);
               ArrayResize(pricesSellSide, n+1);
               pricesSellSide[n] = openPrice;
              }
           }
        }
     }
  }

int CountPositions(ENUM_POSITION_TYPE type)
  {
   int count = 0;
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber &&
            PositionGetString(POSITION_SYMBOL)==_Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==type)
           {
            count++;
           }
        }
     }
   return count;
  }

int CountPendingOrders(ENUM_ORDER_TYPE type)
  {
   int count = 0;
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetInteger(ORDER_MAGIC)==MagicNumber &&
            OrderGetString(ORDER_SYMBOL)==_Symbol &&
            (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)==type)
           {
            count++;
           }
        }
     }
   return count;
  }

void CheckCloseOnCandleIfProfit()
{
   if(BuyMode == BUY_CLOSE_CANDLE && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      double totalProfitBuy = 0.0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               totalProfitBuy += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            }
         }
      }
      if(totalProfitBuy > 0.0)
      {
         Print("✅ CLOSE_CANDLE BUY: Profit global positif (", DoubleToString(totalProfitBuy, 2), " €) - Fermeture de tous les BUY");
         CloseAllTrades(POSITION_TYPE_BUY);
      }
      else
      {
         Print("⏳ CLOSE_CANDLE BUY: Profit global négatif ou nul (", DoubleToString(totalProfitBuy, 2), " €) - Attente bougie suivante");
      }
   }
   if(SellMode == SELL_CLOSE_CANDLE && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      double totalProfitSell = 0.0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               totalProfitSell += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            }
         }
      }
      if(totalProfitSell > 0.0)
      {
         Print("✅ CLOSE_CANDLE SELL: Profit global positif (", DoubleToString(totalProfitSell, 2), " €) - Fermeture de tous les SELL");
         CloseAllTrades(POSITION_TYPE_SELL);
      }
      else
      {
         Print("⏳ CLOSE_CANDLE SELL: Profit global négatif ou nul (", DoubleToString(totalProfitSell, 2), " €) - Attente bougie suivante");
      }
   }
}

double GetAdjustedAsk()
  {
   double basePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(BackTestMode)
      return basePrice + (BackTestSpread * _Point);
   return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  }

double GetAdjustedBid()
  {
   if(BackTestMode)
      return SymbolInfoDouble(_Symbol, SYMBOL_BID);
   return SymbolInfoDouble(_Symbol, SYMBOL_BID);
  }

bool IsValidTradingTime(ENUM_TIMEFRAMES timeframe, bool isBuy)
  {
   datetime serverTime = TimeCurrent();
   MqlDateTime serverTimeStruct;
   TimeToStruct(serverTime, serverTimeStruct);
   int periodMinutes;
   switch(timeframe)
     {
      case PERIOD_M1:  periodMinutes = 1;   break;
      case PERIOD_M2:  periodMinutes = 2;   break;
      case PERIOD_M3:  periodMinutes = 3;   break;
      case PERIOD_M4:  periodMinutes = 4;   break;
      case PERIOD_M5:  periodMinutes = 5;   break;
      case PERIOD_M6:  periodMinutes = 6;   break;
      case PERIOD_M10: periodMinutes = 10;  break;
      case PERIOD_M12: periodMinutes = 12;  break;
      case PERIOD_M15: periodMinutes = 15;  break;
      case PERIOD_M20: periodMinutes = 20;  break;
      case PERIOD_M30: periodMinutes = 30;  break;
      case PERIOD_H1:  periodMinutes = 60;  break;
      case PERIOD_H2:  periodMinutes = 120; break;
      case PERIOD_H3:  periodMinutes = 180; break;
      case PERIOD_H4:  periodMinutes = 240; break;
      case PERIOD_H6:  periodMinutes = 360; break;
      case PERIOD_H8:  periodMinutes = 480; break;
      case PERIOD_H12: periodMinutes = 720; break;
      case PERIOD_D1:  periodMinutes = 1440;break;
      case PERIOD_W1:  periodMinutes = 10080; break;
      case PERIOD_MN1: periodMinutes = 43200; break;
      default:
         return false;
     }
   int currentTimeInMinutes = serverTimeStruct.hour * 60 + serverTimeStruct.min;
   int startTimeInMinutes;
   if(isBuy)
      startTimeInMinutes = StartHourBuy * 60 + StartMinuteBuy;
   else
      startTimeInMinutes = StartHourSell * 60 + StartMinuteSell;
   int elapsedMinutes = currentTimeInMinutes - startTimeInMinutes;
   if(elapsedMinutes < 0)
      elapsedMinutes += 1440;
   bool isValidTime = (elapsedMinutes % periodMinutes == 0);
   return isValidTime;
  }

double GetAccumulatedSwapCost(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket))
      return 0.0;
   double totalCosts = PositionGetDouble(POSITION_SWAP);
   ulong positionId = PositionGetInteger(POSITION_IDENTIFIER);
   if(HistorySelectByPosition(positionId))
     {
      int deals = HistoryDealsTotal();
      for(int i = 0; i < deals; i++)
        {
         ulong dealTicket = HistoryDealGetTicket(i);
         if(dealTicket > 0)
           {
            totalCosts += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
           }
        }
     }
   return totalCosts;
  }

double GetAverageCommissionFromHistory()
{
   datetime startTime = TimeCurrent() - 7*24*60*60; // 7 derniers jours
   datetime endTime = TimeCurrent();
   if(!HistorySelect(startTime, endTime))
      return 0.0;
   int totalDeals = HistoryDealsTotal();
   double totalCommission = 0.0;
   double totalVolume = 0.0;
   int validDeals = 0;
   for(int i = 0; i < totalDeals; i++)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket <= 0) continue;
      string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      if(dealSymbol == _Symbol && dealMagic == MagicNumber)
      {
         double commission = MathAbs(HistoryDealGetDouble(dealTicket, DEAL_COMMISSION));
         double dealVolume = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
         if(commission > 0 && dealVolume > 0)
         {
            totalCommission += commission;
            totalVolume += dealVolume;
            validDeals++;
         }
      }
   }
   
   if(validDeals > 0 && totalVolume > 0)
   {
      return totalCommission / totalVolume;
   }
   
   return 0.0; // Pas d'historique disponible
}

double GetRealBrokerFees(double volume, ENUM_POSITION_TYPE type)
{
   double totalFees = 0.0;
   double realSwap = 0.0;
   if(type == POSITION_TYPE_BUY)
      realSwap = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   else
      realSwap = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
   double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double swapCost = MathAbs(realSwap * volume * pointValue);
   totalFees += swapCost;
   double avgCommissionPerLot = GetAverageCommissionFromHistory();
   if(avgCommissionPerLot > 0)
   {
      totalFees += avgCommissionPerLot * volume;
   }
   else
   {
      double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      double currentPrice = (type == POSITION_TYPE_BUY) ? GetAdjustedAsk() : GetAdjustedBid();
      double notionalValue = volume * contractSize * currentPrice;
      totalFees += notionalValue * EstimatedCommissionRate;
   }
   
   return totalFees;
}

double EstimateBrokerFees(double volume, ENUM_POSITION_TYPE type)
{
   if(!EnableBrokerFeeCompensation)
      return 0.0;
   if(AutoDetectBrokerFees)
   {
      return GetRealBrokerFees(volume, type);
   }
   
   double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double currentPrice = (type == POSITION_TYPE_BUY) ? GetAdjustedAsk() : GetAdjustedBid();
   double notionalValue = volume * contractSize * currentPrice;
   double estimatedCommission = notionalValue * EstimatedCommissionRate;
   double estimatedSwap = notionalValue * EstimatedSwapRate;
   double totalEstimatedFees = MathAbs(estimatedCommission) + MathAbs(estimatedSwap);
   return totalEstimatedFees;
}

double CalculateTPWithFeeCompensation(double openPrice, double baseTpPips, double volume, ENUM_POSITION_TYPE type)
{
   double point = _Point;
   double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double estimatedFees = EstimateBrokerFees(volume, type);
   double feesInPips = estimatedFees / (volume * contractSize * point);
   double adjustedTpPips = baseTpPips + feesInPips;
   double adjustedTP;
   if(type == POSITION_TYPE_BUY)
      adjustedTP = openPrice + (adjustedTpPips * point);
   else
      adjustedTP = openPrice - (adjustedTpPips * point);
   Print("TP Compensation: Base=", baseTpPips, " pips, Frais=", feesInPips, " pips, Ajusté=", adjustedTpPips, " pips (", estimatedFees, "€ de frais estimés)");
   return NormalizeDouble(adjustedTP, _Digits);
}

void DeleteAllPendingOrdersAfterClose()
  {
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
           {
            ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            if(orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_BUY_LIMIT ||
               orderType == ORDER_TYPE_SELL_STOP || orderType == ORDER_TYPE_SELL_LIMIT)
              {
               trade.OrderDelete(ticket);
              }
           }
        }
     }
  }

bool CanPlaceHelperTrade(ENUM_POSITION_TYPE type)
{
   if(!CanAffordNextTrade(type == POSITION_TYPE_BUY))
   {
      Print("❌ Helper bloqué: Budget insuffisant");
      return false;
   }
   
   int currentTrades = CountPositions(type);
   int maxTrades = (type == POSITION_TYPE_BUY) ? MaxBuyTrades : MaxSellTrades;
   if(currentTrades >= maxTrades)
   {
      Print("❌ Helper bloqué: Limite de trades atteinte (", currentTrades, "/", maxTrades, ")");
      return false;
   }
   
   ENUM_TIMEFRAMES timeframe = (type == POSITION_TYPE_BUY) ? TimeframeBuy : TimeframeSell;
   if(!IsValidTradingTime(timeframe, type == POSITION_TYPE_BUY))
   {
      Print("❌ Helper bloqué: Horaire de trading non valide");
      return false;
   }
   
   bool isPartialClosureMode = (type == POSITION_TYPE_BUY && BuyMode == BUY_PARTIAL_CLOSURE) ||
                               (type == POSITION_TYPE_SELL && SellMode == SELL_PARTIAL_CLOSURE);
   if(!isPartialClosureMode)
   {
      double currentPrice = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      int minDistance = (type == POSITION_TYPE_BUY) ? DistanceMinEntre2TradesBuy : DistanceMinEntre2TradesSell;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double distance = MathAbs(currentPrice - openPrice) / _Point;
               if(distance < minDistance)
               {
                  Print("❌ Helper bloqué: Distance insuffisante (", distance, " < ", minDistance, " points)");
                  return false;
               }
            }
         }
      }
   }
   
   return true;
}

double CalculateTotalPipsWithCosts(ENUM_POSITION_TYPE type)
{
   double totalPips = 0.0;
   double point = _Point;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double volume = PositionGetDouble(POSITION_VOLUME);
            double profit = PositionGetDouble(POSITION_PROFIT);
            double swap = PositionGetDouble(POSITION_SWAP);
            double commission = GetAccumulatedSwapCost(ticket) - swap; // Commission seule
            double currentPrice;
            if(type == POSITION_TYPE_BUY)
               currentPrice = GetAdjustedBid();
            else
               currentPrice = GetAdjustedAsk();
            double pipsFromPrice = (type == POSITION_TYPE_BUY) 
                                 ? (currentPrice - openPrice) / point
                                 : (openPrice - currentPrice) / point;
            double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
            double feeInPips = (swap + commission) / (volume * contractSize * point);
            totalPips += (pipsFromPrice + feeInPips) * volume;
         }
      }
   }
   return totalPips;
}

double GetTotalVolume(ENUM_POSITION_TYPE type)
{
   double totalVolume = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         {
            totalVolume += PositionGetDouble(POSITION_VOLUME);
         }
      }
   }
   return totalVolume;
}

void CloseAllTrades(ENUM_POSITION_TYPE type)
{
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         {
            if(trade.PositionClose(ticket))
               Print("Fermeture ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"), " trade ", ticket);
            else
               Print("Erreur fermeture trade ", ticket, ": ", trade.ResultRetcode());
         }
      }
   }
   if(CountPositions(type) == 0)
      DeleteAllPendingOrdersAfterClose();
}

void CheckCumulativeSingleTP()
{
   if(BuyMode == BUY_CUMUL_SINGLE)
   {
      double totalPipsBuy = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
      if(totalPipsBuy >= InitialTakeProfitBuy)
      {
         Print("CUMUL_SINGLE BUY: TP atteint (", totalPipsBuy, " pips ≥ ", InitialTakeProfitBuy, " pips)");
         CloseAllTrades(POSITION_TYPE_BUY);
      }
   }
   if(SellMode == SELL_CUMUL_SINGLE)
   {
      double totalPipsSell = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
      if(totalPipsSell >= InitialTakeProfitSell)
      {
         Print("CUMUL_SINGLE SELL: TP atteint (", totalPipsSell, " pips ≥ ", InitialTakeProfitSell, " pips)");
         CloseAllTrades(POSITION_TYPE_SELL);
      }
   }
}

void CheckCumulativeMultiTP()
{
   if(BuyMode == BUY_CUMUL_MULTI)
   {
      double totalVolumeBuy = GetTotalVolume(POSITION_TYPE_BUY);
      if(totalVolumeBuy > 0)
      {
         double baseVol = GetBaseVolumeForCalculations(true);
         double volumeMultiplier = totalVolumeBuy / baseVol;
         double targetPips = InitialTakeProfitBuy * volumeMultiplier;
         double totalPipsBuy = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
         if(totalPipsBuy >= targetPips)
         {
            string mode = UseGridVolumeBuy ? "GRID" : "FIXE";
            Print("CUMUL_MULTI BUY (", mode, "): TP atteint (", totalPipsBuy, " pips ≥ ", targetPips, " pips)");
            Print("Volume total: ", totalVolumeBuy, ", Base: ", baseVol, ", Multiplicateur: ", volumeMultiplier);
            CloseAllTrades(POSITION_TYPE_BUY);
         }
      }
   }
   if(SellMode == SELL_CUMUL_MULTI)
   {
      double totalVolumeSell = GetTotalVolume(POSITION_TYPE_SELL);
      if(totalVolumeSell > 0)
      {
         double baseVol = GetBaseVolumeForCalculations(false);
         double volumeMultiplier = totalVolumeSell / baseVol;
         double targetPips = InitialTakeProfitSell * volumeMultiplier;
         double totalPipsSell = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
         if(totalPipsSell >= targetPips)
         {
            string mode = UseGridVolumeSell ? "GRID" : "FIXE";
            Print("CUMUL_MULTI SELL (", mode, "): TP atteint (", totalPipsSell, " pips ≥ ", targetPips, " pips)");
            Print("Volume total: ", totalVolumeSell, ", Base: ", baseVol, ", Multiplicateur: ", volumeMultiplier);
            CloseAllTrades(POSITION_TYPE_SELL);
         }
      }
   }
}

void CheckCumulativePosTP()
{
   if(BuyMode == BUY_CUMUL_POS)
   {
      int nbTradesBuy = CountPositions(POSITION_TYPE_BUY);
      if(nbTradesBuy > 0)
      {
         double reductionFactor = CumulPosReductionFactorBuy;
         double minTPPercent = CumulPosMinTPPercentBuy;
         double tpReductionPercent = 1.0 - (reductionFactor * (nbTradesBuy - 1));
         tpReductionPercent = MathMax(tpReductionPercent, minTPPercent);
         double tpPerPosition = InitialTakeProfitBuy * tpReductionPercent;
         double targetPips = tpPerPosition * nbTradesBuy;
         double totalPipsBuy = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
         if(totalPipsBuy >= targetPips)
         {
            Print("CUMUL_POS BUY: TP atteint avec réduction progressive");
            Print("- Positions: ", nbTradesBuy, " | TP base: ", InitialTakeProfitBuy, " pips");
            Print("- Réduction: ", (1.0-tpReductionPercent)*100, "% | TP par position: ", tpPerPosition, " pips");  
            Print("- Total requis: ", targetPips, " pips | Atteint: ", totalPipsBuy, " pips");
            CloseAllTrades(POSITION_TYPE_BUY);
         }
      }
   }
   if(SellMode == SELL_CUMUL_POS)
   {
      int nbTradesSell = CountPositions(POSITION_TYPE_SELL);
      if(nbTradesSell > 0)
      {
         double reductionFactor = CumulPosReductionFactorSell;
         double minTPPercent = CumulPosMinTPPercentSell;
         double tpReductionPercent = 1.0 - (reductionFactor * (nbTradesSell - 1));
         tpReductionPercent = MathMax(tpReductionPercent, minTPPercent);
         double tpPerPosition = InitialTakeProfitSell * tpReductionPercent;
         double targetPips = tpPerPosition * nbTradesSell;
         double totalPipsSell = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
         if(totalPipsSell >= targetPips)
         {
            Print("CUMUL_POS SELL: TP atteint avec réduction progressive");
            Print("- Positions: ", nbTradesSell, " | TP base: ", InitialTakeProfitSell, " pips");
            Print("- Réduction: ", (1.0-tpReductionPercent)*100, "% | TP par position: ", tpPerPosition, " pips");
            Print("- Total requis: ", targetPips, " pips | Atteint: ", totalPipsSell, " pips");
            CloseAllTrades(POSITION_TYPE_SELL);
         }
      }
   }
}

void CheckLadderProfitTP()
{
   if(BuyMode == BUY_LADDER_PROFIT && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               double pips = (currentPrice - openPrice) / _Point / 10;
               if(pips >= InitialTakeProfitBuy)
               {
                  Print("LADDER_PROFIT BUY: Position ", ticket, " fermée (", pips, " pips ≥ ", InitialTakeProfitBuy, " pips)");
                  trade.PositionClose(ticket);
               }
            }
         }
      }
   }
   
   if(SellMode == SELL_LADDER_PROFIT && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               double pips = (openPrice - currentPrice) / _Point / 10;
               if(pips >= InitialTakeProfitSell)
               {
                  Print("LADDER_PROFIT SELL: Position ", ticket, " fermée (", pips, " pips ≥ ", InitialTakeProfitSell, " pips)");
                  trade.PositionClose(ticket);
               }
            }
         }
      }
   }
}

void CheckWaveRidingTP()
{
   static datetime lastRideTime = 0;
   if(BuyMode == BUY_WAVE_RIDING && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      double totalProfit = 0.0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            }
         }
      }
      
      double quickProfitThreshold = (InitialTakeProfitBuy * 0.3) * CountPositions(POSITION_TYPE_BUY);
      if(totalProfit > quickProfitThreshold && TimeCurrent() > lastRideTime + 60) // 1 minute minimum entre rides
      {
         Print("WAVE_RIDING BUY: Surf de vague détecté - profit rapide (", totalProfit, "€)");
         double totalVolume = GetTotalVolume(POSITION_TYPE_BUY);
         CloseAllTrades(POSITION_TYPE_BUY);
         
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedAsk();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_BUY, currentPrice))
         {
            trade.Buy(totalVolume, _Symbol, currentPrice, 0, 0);
            lastRideTime = TimeCurrent();
            Print("WAVE_RIDING BUY: Nouvelle vague ouverte avec ", totalVolume, " lots");
         }
         else
         {
            Print("❌ WAVE_RIDING BUY: Validation échouée - nouvelle vague annulée");
         }
      }
   }
   
   if(SellMode == SELL_WAVE_RIDING && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      double totalProfit = 0.0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            }
         }
      }
      
      double quickProfitThreshold = (InitialTakeProfitSell * 0.3) * CountPositions(POSITION_TYPE_SELL);
      if(totalProfit > quickProfitThreshold && TimeCurrent() > lastRideTime + 60)
      {
         Print("WAVE_RIDING SELL: Surf de vague détecté - profit rapide (", totalProfit, "€)");
         double totalVolume = GetTotalVolume(POSITION_TYPE_SELL);
         CloseAllTrades(POSITION_TYPE_SELL);
         
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedBid();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_SELL, currentPrice))
         {
            trade.Sell(totalVolume, _Symbol, currentPrice, 0, 0);
            lastRideTime = TimeCurrent();
            Print("WAVE_RIDING SELL: Nouvelle vague ouverte avec ", totalVolume, " lots");
         }
         else
         {
            Print("❌ WAVE_RIDING SELL: Validation échouée - nouvelle vague annulée");
         }
      }
   }
}

void CheckVixReversionTP()
{
   if(StringFind(_Symbol, "VIX") == -1) return;
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(BuyMode == BUY_VIX_REVERSION && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      if(currentPrice >= 22.0) // VIX au-dessus de 22 = probable retour vers 20
      {
         double totalProfit = 0.0;
         for(int i = 0; i < PositionsTotal(); i++)
         {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
               if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                  PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               {
                  totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
               }
            }
         }
         
         if(totalProfit > 0) // Ferme seulement si profitable
         {
            Print("VIX_REVERSION BUY: VIX à ", currentPrice, " - Fermeture profitable (", totalProfit, "€)");
            CloseAllTrades(POSITION_TYPE_BUY);
         }
      }
   }
   
   if(SellMode == SELL_VIX_REVERSION && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      if(currentPrice <= 18.0)
      {
         double totalProfit = 0.0;
         for(int i = 0; i < PositionsTotal(); i++)
         {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
               if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                  PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
               {
                  totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
               }
            }
         }
         
         if(totalProfit > 0)
         {
            Print("VIX_REVERSION SELL: VIX à ", currentPrice, " - Fermeture profitable (", totalProfit, "€)");
            CloseAllTrades(POSITION_TYPE_SELL);
         }
      }
   }
}

void CheckMomentumBurstTP()
{
   if(BuyMode == BUY_MOMENTUM_BURST && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      int closedPositions = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
               double quickBurstThreshold = InitialTakeProfitBuy * 0.2;
               if(profit >= quickBurstThreshold)
               {
                  Print("MOMENTUM_BURST BUY: Position ", ticket, " fermée rapidement (", profit, "€ ≥ ", quickBurstThreshold, "€)");
                  trade.PositionClose(ticket);
                  closedPositions++;
               }
            }
         }
      }
      
      for(int i = 0; i < closedPositions * 2; i++)
      {
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedAsk();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_BUY, currentPrice))
         {
            int currentTrades = CountPositions(POSITION_TYPE_BUY);
            double newVolume = CalculateTradeVolume(true, currentTrades) * 0.5; // Lots plus petits pour mitrailler
            if(newVolume >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
            {
               trade.Buy(newVolume, _Symbol, currentPrice, 0, 0);
               Print("MOMENTUM_BURST BUY: Nouvelle salve - ", newVolume, " lots à ", currentPrice);
            }
         }
         else
         {
            Print("❌ MOMENTUM_BURST BUY: Validation échouée - salve #", i+1, " annulée");
            break; // Arrêter si validation échoue
         }
      }
   }
   
   if(SellMode == SELL_MOMENTUM_BURST && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      int closedPositions = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
               double quickBurstThreshold = InitialTakeProfitSell * 0.2;
               if(profit >= quickBurstThreshold)
               {
                  Print("MOMENTUM_BURST SELL: Position ", ticket, " fermée rapidement (", profit, "€ ≥ ", quickBurstThreshold, "€)");
                  trade.PositionClose(ticket);
                  closedPositions++;
               }
            }
         }
      }
      
      for(int i = 0; i < closedPositions * 2; i++)
      {
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedBid();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_SELL, currentPrice))
         {
            int currentTrades = CountPositions(POSITION_TYPE_SELL);
            double newVolume = CalculateTradeVolume(false, currentTrades) * 0.5;
            if(newVolume >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
            {
               trade.Sell(newVolume, _Symbol, currentPrice, 0, 0);
               Print("MOMENTUM_BURST SELL: Nouvelle salve - ", newVolume, " lots à ", currentPrice);
            }
         }
         else
         {
            Print("❌ MOMENTUM_BURST SELL: Validation échouée - salve #", i+1, " annulée");
            break; // Arrêter si validation échoue
         }
      }
   }
}

void CheckScalpAccumulatorTP()
{
   if(BuyMode == BUY_SCALP_ACCUMULATOR && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      int closedPositions = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               double pips = (currentPrice - openPrice) / _Point / 10;
               double scalpTarget = InitialTakeProfitBuy * 0.15;
               if(pips >= scalpTarget)
               {
                  Print("SCALP_ACCUMULATOR BUY: Scalp réussi - Position ", ticket, " fermée (", pips, " pips ≥ ", scalpTarget, " pips)");
                  trade.PositionClose(ticket);
                  closedPositions++;
               }
            }
         }
      }
      
      for(int i = 0; i < closedPositions; i++)
      {
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedAsk();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_BUY, currentPrice))
         {
            int currentTrades = CountPositions(POSITION_TYPE_BUY);
            double volume = CalculateTradeVolume(true, currentTrades);
            trade.Buy(volume, _Symbol, currentPrice, 0, 0);
            Print("SCALP_ACCUMULATOR BUY: Nouveau scalp lancé - ", volume, " lots à ", currentPrice);
         }
         else
         {
            Print("❌ SCALP_ACCUMULATOR BUY: Validation échouée - scalp #", i+1, " annulé");
            break; // Arrêter si validation échoue
         }
      }
   }
   
   if(SellMode == SELL_SCALP_ACCUMULATOR && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      int closedPositions = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               double pips = (openPrice - currentPrice) / _Point / 10;
               double scalpTarget = InitialTakeProfitSell * 0.15;
               if(pips >= scalpTarget)
               {
                  Print("SCALP_ACCUMULATOR SELL: Scalp réussi - Position ", ticket, " fermée (", pips, " pips ≥ ", scalpTarget, " pips)");
                  trade.PositionClose(ticket);
                  closedPositions++;
               }
            }
         }
      }
      
      for(int i = 0; i < closedPositions; i++)
      {
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedBid();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_SELL, currentPrice))
         {
            int currentTrades = CountPositions(POSITION_TYPE_SELL);
            double volume = CalculateTradeVolume(false, currentTrades);
            trade.Sell(volume, _Symbol, currentPrice, 0, 0);
            Print("SCALP_ACCUMULATOR SELL: Nouveau scalp lancé - ", volume, " lots à ", currentPrice);
         }
         else
         {
            Print("❌ SCALP_ACCUMULATOR SELL: Validation échouée - scalp #", i+1, " annulé");
            break; // Arrêter si validation échoue
         }
      }
   }
}

void CheckVixOscillationMasterTP()
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(BuyMode == BUY_VIX_OSCILLATION_MASTER && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               bool shouldClose = false;
               string reason = "";
               if(openPrice >= 20.0 && currentPrice >= 22.0)
               {
                  shouldClose = true;
                  reason = "Retour VIX vers équilibre (acheté ≥20, VIX ≥22)";
               }
               else if(openPrice >= 18.0 && openPrice < 20.0 && currentPrice >= 21.0)
               {
                  shouldClose = true;
                  reason = "VIX haussier confirmé (acheté 18-20, VIX ≥21)";
               }
               else if(openPrice >= 16.0 && openPrice < 18.0 && currentPrice >= 19.5)
               {
                  shouldClose = true;
                  reason = "Rebond VIX bas confirmé (acheté 16-18, VIX ≥19.5)";
               }
               else if(openPrice < 16.0 && currentPrice >= 18.0)
               {
                  shouldClose = true;
                  reason = "VIX extrêmement bas - rebond garanti (acheté <16, VIX ≥18)";
               }
               
               if(shouldClose)
               {
                  double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
                  Print("VIX_OSCILLATION_MASTER BUY: ", reason, " - Position ", ticket, " fermée (", profit, "€)");
                  trade.PositionClose(ticket);
               }
            }
         }
      }
   }
   
   if(SellMode == SELL_VIX_OSCILLATION_MASTER && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               bool shouldClose = false;
               string reason = "";
               if(openPrice <= 20.0 && currentPrice <= 18.0)
               {
                  shouldClose = true;
                  reason = "VIX retourne vers plancher (vendu ≤20, VIX ≤18)";
               }
               else if(openPrice <= 22.0 && openPrice > 20.0 && currentPrice <= 19.0)
               {
                  shouldClose = true;
                  reason = "VIX baissier confirmé (vendu 20-22, VIX ≤19)";
               }
               else if(openPrice <= 24.0 && openPrice > 22.0 && currentPrice <= 20.5)
               {
                  shouldClose = true;
                  reason = "Correction VIX haut confirmée (vendu 22-24, VIX ≤20.5)";
               }
               else if(openPrice > 24.0 && currentPrice <= 22.0)
               {
                  shouldClose = true;
                  reason = "VIX extrêmement haut - chute garantie (vendu >24, VIX ≤22)";
               }
               
               if(shouldClose)
               {
                  double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
                  Print("VIX_OSCILLATION_MASTER SELL: ", reason, " - Position ", ticket, " fermée (", profit, "€)");
                  trade.PositionClose(ticket);
               }
            }
         }
      }
   }
}

void CheckProfitCompoundingTP()
{
   if(BuyMode == BUY_PROFIT_COMPOUNDING && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      int closedPositions = 0;
      double totalProfit = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               double pips = (currentPrice - openPrice) / _Point / 10;
               double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
               if(pips >= InitialTakeProfitBuy)
               {
                  Print("PROFIT_COMPOUNDING BUY: Position ", ticket, " fermée (", pips, " pips, profit: ", profit, "€)");
                  trade.PositionClose(ticket);
                  closedPositions++;
                  totalProfit += profit;
               }
            }
         }
      }
      
      for(int i = 0; i < closedPositions; i++)
      {
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedAsk();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_BUY, currentPrice))
         {
            int currentTrades = CountPositions(POSITION_TYPE_BUY);
            double baseVolume = CalculateTradeVolume(true, currentTrades);
            double compoundMultiplier = 1.0;
            if(totalProfit > 50) compoundMultiplier = 1.2;      // +20% si profit > 50€
            if(totalProfit > 100) compoundMultiplier = 1.5;     // +50% si profit > 100€
            if(totalProfit > 200) compoundMultiplier = 2.0;     // +100% si profit > 200€
            double compoundedVolume = baseVolume * compoundMultiplier;
            double maxVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
            if(compoundedVolume > maxVolume) compoundedVolume = maxVolume;
            trade.Buy(compoundedVolume, _Symbol, currentPrice, 0, 0);
            Print("PROFIT_COMPOUNDING BUY: Réinvestissement amplifié - ", compoundedVolume, " lots (x", compoundMultiplier, ") à ", currentPrice);
         }
         else
         {
            Print("❌ PROFIT_COMPOUNDING BUY: Validation échouée - réinvestissement #", i+1, " annulé");
            break; // Arrêter si validation échoue
         }
      }
   }
   
   if(SellMode == SELL_PROFIT_COMPOUNDING && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      int closedPositions = 0;
      double totalProfit = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               double pips = (openPrice - currentPrice) / _Point / 10;
               double profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
               if(pips >= InitialTakeProfitSell)
               {
                  Print("PROFIT_COMPOUNDING SELL: Position ", ticket, " fermée (", pips, " pips, profit: ", profit, "€)");
                  trade.PositionClose(ticket);
                  closedPositions++;
                  totalProfit += profit;
               }
            }
         }
      }
      
      for(int i = 0; i < closedPositions; i++)
      {
         // VALIDATION COMPLÈTE avant placement
         double currentPrice = GetAdjustedBid();
         if(CanPlaceTradeWithFullValidation(POSITION_TYPE_SELL, currentPrice))
         {
            int currentTrades = CountPositions(POSITION_TYPE_SELL);
            double baseVolume = CalculateTradeVolume(false, currentTrades);
            double compoundMultiplier = 1.0;
            if(totalProfit > 50) compoundMultiplier = 1.2;
            if(totalProfit > 100) compoundMultiplier = 1.5;
            if(totalProfit > 200) compoundMultiplier = 2.0;
            double compoundedVolume = baseVolume * compoundMultiplier;
            double maxVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
            if(compoundedVolume > maxVolume) compoundedVolume = maxVolume;
            trade.Sell(compoundedVolume, _Symbol, currentPrice, 0, 0);
            Print("PROFIT_COMPOUNDING SELL: Réinvestissement amplifié - ", compoundedVolume, " lots (x", compoundMultiplier, ") à ", currentPrice);
         }
         else
         {
            Print("❌ PROFIT_COMPOUNDING SELL: Validation échouée - réinvestissement #", i+1, " annulé");
            break; // Arrêter si validation échoue
         }
      }
   }
}

void CheckBreakoutSurferTP()
{
   static double lastPrice = 0;
   static datetime lastBarTime = 0;
   static bool momentumDetected = false;
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   datetime currentBarTime = iTime(_Symbol, PERIOD_M1, 0);
   if(currentBarTime != lastBarTime)
   {
      if(lastPrice > 0)
      {
         double priceChange = MathAbs(currentPrice - lastPrice);
         double momentum = priceChange / _Point / 10; // En pips
         momentumDetected = (momentum > 50);
         if(momentumDetected)
         {
            Print("BREAKOUT_SURFER: Momentum détecté - ", momentum, " pips en 1 minute");
         }
      }
      lastBarTime = currentBarTime;
   }
   lastPrice = currentPrice;
   if(BuyMode == BUY_BREAKOUT_SURFER && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double pips = (currentPrice - openPrice) / _Point / 10;
               double surfTarget = InitialTakeProfitBuy * 0.7;
               if(pips >= surfTarget)
               {
                  Print("BREAKOUT_SURFER BUY: Vague surfée - Position ", ticket, " fermée (", pips, " pips ≥ ", surfTarget, " pips)");
                  trade.PositionClose(ticket);
                  
                  // VALIDATION COMPLÈTE avant placement
                  double askPrice = GetAdjustedAsk();
                  if(momentumDetected && CanPlaceTradeWithFullValidation(POSITION_TYPE_BUY, askPrice))
                  {
                     int currentTrades = CountPositions(POSITION_TYPE_BUY);
                     double volume = CalculateTradeVolume(true, currentTrades);
                     trade.Buy(volume, _Symbol, askPrice, 0, 0);
                     Print("BREAKOUT_SURFER BUY: Nouveau surf lancé - ", volume, " lots à ", askPrice);
                  }
                  else if(momentumDetected)
                  {
                     Print("❌ BREAKOUT_SURFER BUY: Validation échouée - nouveau surf annulé");
                  }
               }
            }
         }
      }
   }
   
   if(SellMode == SELL_BREAKOUT_SURFER && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double askPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               double pips = (openPrice - askPrice) / _Point / 10;
               double surfTarget = InitialTakeProfitSell * 0.7;
               if(pips >= surfTarget)
               {
                  Print("BREAKOUT_SURFER SELL: Vague surfée - Position ", ticket, " fermée (", pips, " pips ≥ ", surfTarget, " pips)");
                  trade.PositionClose(ticket);
                  
                  // VALIDATION COMPLÈTE avant placement
                  double bidPrice = GetAdjustedBid();
                  if(momentumDetected && CanPlaceTradeWithFullValidation(POSITION_TYPE_SELL, bidPrice))
                  {
                     int currentTrades = CountPositions(POSITION_TYPE_SELL);
                     double volume = CalculateTradeVolume(false, currentTrades);
                     trade.Sell(volume, _Symbol, bidPrice, 0, 0);
                     Print("BREAKOUT_SURFER SELL: Nouveau surf lancé - ", volume, " lots à ", bidPrice);
                  }
                  else if(momentumDetected)
                  {
                     Print("❌ BREAKOUT_SURFER SELL: Validation échouée - nouveau surf annulé");
                  }
               }
            }
         }
      }
   }
}

struct PartialTradeInfo
{
   ulong    ticket;          // Ticket du trade principal
   double   initialVolume;   // Volume initial (ex: 1.0)
   double   remainingVolume; // Volume restant (ex: 0.9, 0.8...)
   double   openPrice;       // Prix d'ouverture initial
   double   unitSize;        // Taille unitaire (ex: 0.1)
   int      unitsRemaining;  // Unités restantes (ex: 9, 8...)
   ulong    lastHelperTicket; // Dernier ticket d'aide placé
   PartialTradeInfo() {}
   PartialTradeInfo(const PartialTradeInfo &src) 
   {
      ticket          = src.ticket;
      initialVolume   = src.initialVolume;
      remainingVolume = src.remainingVolume;
      openPrice       = src.openPrice;
      unitSize        = src.unitSize;
      unitsRemaining  = src.unitsRemaining;
      lastHelperTicket= src.lastHelperTicket;
   }
};
PartialTradeInfo buyPartialTrades[];   // Array des trades BUY partiels
PartialTradeInfo sellPartialTrades[];  // Array des trades SELL partiels
void AddToPartialSystem(ulong ticket, double volume, double openPrice, ENUM_POSITION_TYPE type)
{
   double optimalUnitSize = CalculateOptimalUnitSize(volume);
   int possibleUnits = (int)(volume / optimalUnitSize);
   if(possibleUnits < 2)
   {
      Print("⚠️ Volume trop petit pour clôture partielle : ", volume, " lots");
      Print("   Minimum requis: ", optimalUnitSize * 2, " lots pour 2 unités");
      return;
   }
   
   PartialTradeInfo newTrade;
   newTrade.ticket = ticket;
   newTrade.initialVolume = volume;
   newTrade.remainingVolume = volume;
   newTrade.openPrice = openPrice;
   newTrade.unitSize = optimalUnitSize;
   newTrade.unitsRemaining = possibleUnits;
   newTrade.lastHelperTicket = 0;
   if(type == POSITION_TYPE_BUY)
   {
      ArrayResize(buyPartialTrades, ArraySize(buyPartialTrades) + 1);
      buyPartialTrades[ArraySize(buyPartialTrades) - 1] = newTrade;
   }
   else
   {
      ArrayResize(sellPartialTrades, ArraySize(sellPartialTrades) + 1);
      sellPartialTrades[ArraySize(sellPartialTrades) - 1] = newTrade;
   }
   Print("✅ Trade ", ticket, " ajouté au système partiel :");
   Print("   📊 Volume: ", volume, " = ", possibleUnits, " unités de ", optimalUnitSize);
}

bool CheckMainTradeTP(PartialTradeInfo &tradeInfo, ENUM_POSITION_TYPE type)
{
   if(!PositionSelectByTicket(tradeInfo.ticket)) return false;
   double currentPrice = (type == POSITION_TYPE_BUY) ? GetAdjustedBid() : GetAdjustedAsk();
   double openPrice = tradeInfo.openPrice;
   double targetPips = (type == POSITION_TYPE_BUY) ? InitialTakeProfitBuy : InitialTakeProfitSell;
   double profitPips = (type == POSITION_TYPE_BUY) 
                     ? (currentPrice - openPrice) / _Point
                     : (openPrice - currentPrice) / _Point;
   if(profitPips >= targetPips)
   {
      Print("🎯 Trade principal ", tradeInfo.ticket, " atteint TP complet (", profitPips, " ≥ ", targetPips, " pips)");
      if(trade.PositionClose(tradeInfo.ticket))
      {
         if(tradeInfo.lastHelperTicket > 0)
         {
            trade.PositionClose(tradeInfo.lastHelperTicket);
         }
         return true;
      }
   }
   return false;
}

void PlaceHelperTrade(PartialTradeInfo &tradeInfo, ENUM_POSITION_TYPE type)
{
   double currentPrice = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double gridDistance = (type == POSITION_TYPE_BUY) ? DistanceOrderBuy : DistanceOrderSell;
   double priceDistance = (type == POSITION_TYPE_BUY) 
                        ? (tradeInfo.openPrice - currentPrice) / _Point
                        : (currentPrice - tradeInfo.openPrice) / _Point;
   int currentGridLevel = (int)(priceDistance / gridDistance);
   Print("🔍 PlaceHelperTrade: Prix=", currentPrice, ", PrixOuverture=", tradeInfo.openPrice, ", Distance=", priceDistance, " points, Niveau grille=", currentGridLevel);
   if(currentGridLevel > 0 && tradeInfo.unitsRemaining > 0)
   {
      bool hasHelperAtLevel = false;
      int helpersCount = 0;
      for(int i = PositionsTotal()-1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
            {
               double posVolume = PositionGetDouble(POSITION_VOLUME);
               if(MathAbs(posVolume - tradeInfo.unitSize) < 0.001)
               {
                  helpersCount++;
               }
            }
         }
      }
      
      int maxHelpersAllowed = MathMin(currentGridLevel, tradeInfo.unitsRemaining);
      if(helpersCount < maxHelpersAllowed)
      {
         double currentPrice = (type == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
         
         // VALIDATION COMPLÈTE avec la nouvelle fonction centralisée
         if(!CanPlaceTradeWithFullValidation(type, currentPrice))
         {
            Print("❌ Helper bloqué: Validation complète échouée");
            return;
         }
         
         // Validations spécifiques aux helpers (prix avantageux)
         bool nouvelOrdreAvantageux = (type == POSITION_TYPE_BUY) ? NouveauxOrdresAPrixPlusAvantageuxBuy : NouveauxOrdresAPrixPlusAvantageuxSell;
         if(nouvelOrdreAvantageux)
         {
            double allPrices[];
            int minDistance = (type == POSITION_TYPE_BUY) ? DistanceMinEntre2TradesBuy : DistanceMinEntre2TradesSell;
            if(type == POSITION_TYPE_BUY)
               GetAllBuySidePrices(allPrices);
            else
               GetAllSellSidePrices(allPrices);
            int priceCount = ArraySize(allPrices);
            if(priceCount > 0)
            {
               if(type == POSITION_TYPE_BUY)
               {
                  double lowestBuy = allPrices[0];
                  for(int i = 1; i < priceCount; i++)
                     lowestBuy = MathMin(lowestBuy, allPrices[i]);
                  double minPriceAllowed = lowestBuy - minDistance * _Point;
                  if(currentPrice > minPriceAllowed)
                  {
                     Print("❌ Helper bloqué: Prix non avantageux (", currentPrice, " > ", minPriceAllowed, ")");
                     return;
                  }
               }
               else
               {
                  double highestSell = allPrices[0];
                  for(int i = 1; i < priceCount; i++)
                     highestSell = MathMax(highestSell, allPrices[i]);
                  double minPriceAllowed = highestSell + minDistance * _Point;
                  if(currentPrice < minPriceAllowed)
                  {
                     Print("❌ Helper bloqué: Prix non avantageux (", currentPrice, " < ", minPriceAllowed, ")");
                     return;
                  }
               }
            }
         }
         
         trade.SetExpertMagicNumber(MagicNumber);
         bool success = false;
         ulong newHelperTicket = 0;
         if(type == POSITION_TYPE_BUY)
         {
            success = trade.Buy(tradeInfo.unitSize, _Symbol);
         }
         else
         {
            success = trade.Sell(tradeInfo.unitSize, _Symbol);
         }
         
         if(success)
         {
            newHelperTicket = trade.ResultOrder();
            tradeInfo.lastHelperTicket = newHelperTicket; // Keep track of most recent helper
            Print("🆘 Helper ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"), " placé : ", newHelperTicket, " (", tradeInfo.unitSize, " lots) - Helper #", helpersCount + 1, "/", maxHelpersAllowed);
         }
         else
         {
            Print("❌ Erreur Helper ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"), " : ", trade.ResultRetcode());
         }
      }
      else
      {
         Print("✅ Helpers suffisants: ", helpersCount, "/", maxHelpersAllowed, " pour niveau grille ", currentGridLevel);
      }
   }
   else
   {
      Print("⏳ Conditions non remplies: Niveau grille=", currentGridLevel, ", Unités restantes=", tradeInfo.unitsRemaining);
   }
}

bool CheckCombinedTP(PartialTradeInfo &tradeInfo, ENUM_POSITION_TYPE type)
{
   if(!PositionSelectByTicket(tradeInfo.ticket)) return false;
   double mainProfit = PositionGetDouble(POSITION_PROFIT);
   double mainSwap = PositionGetDouble(POSITION_SWAP);
   double targetPips = (type == POSITION_TYPE_BUY) ? InitialTakeProfitBuy : InitialTakeProfitSell;
   double targetMoney = targetPips * _Point * tradeInfo.unitSize * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   bool anyHelperClosed = false;
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong helperTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(helperTicket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type &&
            helperTicket != tradeInfo.ticket)
         {
            double helperVolume = PositionGetDouble(POSITION_VOLUME);
            if(MathAbs(helperVolume - tradeInfo.unitSize) < 0.001)
            {
               double helperProfit = PositionGetDouble(POSITION_PROFIT);
               double helperSwap = PositionGetDouble(POSITION_SWAP);
               double unitProfit = (mainProfit + mainSwap) * (tradeInfo.unitSize / tradeInfo.remainingVolume);
               double combinedProfit = helperProfit + helperSwap + unitProfit;
               double helperTP = PositionGetDouble(POSITION_TP);
               if(helperTP == 0.0)
               {
                  double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
                  double newTP;
                  if(type == POSITION_TYPE_BUY)
                     newTP = NormalizeDouble(openPrice + (targetPips * _Point), _Digits);
                  else
                     newTP = NormalizeDouble(openPrice - (targetPips * _Point), _Digits);
                  trade.PositionModify(helperTicket, PositionGetDouble(POSITION_SL), newTP);
                  Print("🎯 TP défini pour helper ", helperTicket, ": ", newTP);
               }
               
               if(combinedProfit >= targetMoney)
               {
                  Print("🎯 TP combiné atteint ! Helper ", helperTicket, " + 1 unité = ", combinedProfit, "€ ≥ ", targetMoney, "€");
                  if(trade.PositionClose(helperTicket))
                  {
                     Print("📉 Helper ", helperTicket, " fermé - Début grignotage du trade principal");
                     if(tradeInfo.unitsRemaining > 1)
                     {
                        if(trade.PositionClosePartial(tradeInfo.ticket, tradeInfo.unitSize))
                        {
                           Print("🥄 Grignotage réussi - ", tradeInfo.unitSize, " lots fermés du trade principal ", tradeInfo.ticket);
                           tradeInfo.remainingVolume -= tradeInfo.unitSize;
                           tradeInfo.unitsRemaining--;
                           if(PositionSelectByTicket(tradeInfo.ticket))
                           {
                              double actualVolume = PositionGetDouble(POSITION_VOLUME);
                              Print("✅ Volume restant vérifié: logique=", tradeInfo.remainingVolume, ", réel=", actualVolume, " (", tradeInfo.unitsRemaining, " unités)");
                           }
                           
                           anyHelperClosed = true;
                        }
                        else
                        {
                           Print("❌ Erreur grignotage partiel du trade principal: ", trade.ResultRetcode());
                        }
                     }
                     else
                     {
                        if(trade.PositionClose(tradeInfo.ticket))
                        {
                           Print("🏁 Cycle terminé - Dernière unité du trade principal ", tradeInfo.ticket, " fermée");
                           tradeInfo.remainingVolume = 0;
                           tradeInfo.unitsRemaining = 0;
                           return true; // Signal to remove from system
                        }
                        else
                        {
                           Print("❌ Erreur fermeture finale du trade principal: ", trade.ResultRetcode());
                        }
                     }
                  }
                  else
                  {
                     Print("❌ Erreur fermeture helper: ", trade.ResultRetcode());
                  }
               }
            }
         }
      }
   }
   
   return false; // Continue the cycle
}

void ManagePartialClosureSystem()
{
   if(ArraySize(buyPartialTrades) > 0)
      Print("🔍 ManagePartialClosureSystem: ", ArraySize(buyPartialTrades), " systèmes BUY actifs");
   for(int i = ArraySize(buyPartialTrades) - 1; i >= 0; i--)
   {
      Print("🔄 Traitement système BUY ", i, ": ticket=", buyPartialTrades[i].ticket, ", volume=", buyPartialTrades[i].remainingVolume, ", unités=", buyPartialTrades[i].unitsRemaining);
      bool mainTradeExists = PositionSelectByTicket(buyPartialTrades[i].ticket);
      bool isPendingOrder = false;
      if(!mainTradeExists)
      {
         if(OrderSelect(buyPartialTrades[i].ticket))
         {
            isPendingOrder = true;
            Print("🔄 Trade principal ", buyPartialTrades[i].ticket, " encore en attente d'exécution");
         }
         else
         {
            bool foundNewPosition = false;
            for(int j = 0; j < PositionsTotal(); j++)
            {
               ulong posTicket = PositionGetTicket(j);
               if(PositionSelectByTicket(posTicket))
               {
                  if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                     PositionGetString(POSITION_SYMBOL) == _Symbol &&
                     (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
                     MathAbs(PositionGetDouble(POSITION_VOLUME) - buyPartialTrades[i].initialVolume) < 0.001 &&
                     MathAbs(PositionGetDouble(POSITION_PRICE_OPEN) - buyPartialTrades[i].openPrice) < 0.001)
                  {
                     Print("🔄 Trade principal trouvé avec nouveau ticket: ", posTicket, " (ancien: ", buyPartialTrades[i].ticket, ")");
                     buyPartialTrades[i].ticket = posTicket;
                     foundNewPosition = true;
                     mainTradeExists = true;
                     break;
                  }
               }
            }
            
            if(!foundNewPosition)
            {
               Print("⚠️ Trade principal ", buyPartialTrades[i].ticket, " n'existe plus - nettoyage du système partiel");
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong helperTicket = PositionGetTicket(j);
                  if(PositionSelectByTicket(helperTicket))
                  {
                     if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                        PositionGetString(POSITION_SYMBOL) == _Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                     {
                        double helperVolume = PositionGetDouble(POSITION_VOLUME);
                        if(MathAbs(helperVolume - buyPartialTrades[i].unitSize) < 0.001)
                        {
                           Print("🧹 Fermeture helper orphelin: ", helperTicket, " (", helperVolume, " lots)");
                           trade.PositionClose(helperTicket);
                        }
                     }
                  }
               }
               
               Print("🏁 Cycle BUY ", buyPartialTrades[i].ticket, " nettoyé - système supprimé");
               ArrayRemove(buyPartialTrades, i, 1);
               continue;
            }
         }
      }
      
      if(isPendingOrder)
      {
         continue;
      }
      
      if(CheckMainTradeTP(buyPartialTrades[i], POSITION_TYPE_BUY))
      {
         Print("🎯 Trade principal ", buyPartialTrades[i].ticket, " atteint TP complet - fin de cycle");
         ArrayRemove(buyPartialTrades, i, 1);
         continue;
      }
      PlaceHelperTrade(buyPartialTrades[i], POSITION_TYPE_BUY);
      if(CheckCombinedTP(buyPartialTrades[i], POSITION_TYPE_BUY))
      {
         Print("🏁 Cycle BUY ", buyPartialTrades[i].ticket, " terminé après TP combiné");
         ArrayRemove(buyPartialTrades, i, 1);
         continue;
      }
   }
   
   if(ArraySize(sellPartialTrades) > 0)
      Print("🔍 ManagePartialClosureSystem: ", ArraySize(sellPartialTrades), " systèmes SELL actifs");
   for(int i = ArraySize(sellPartialTrades) - 1; i >= 0; i--)
   {
      Print("🔄 Traitement système SELL ", i, ": ticket=", sellPartialTrades[i].ticket, ", volume=", sellPartialTrades[i].remainingVolume, ", unités=", sellPartialTrades[i].unitsRemaining);
      bool mainTradeExists = PositionSelectByTicket(sellPartialTrades[i].ticket);
      bool isPendingOrder = false;
      if(!mainTradeExists)
      {
         if(OrderSelect(sellPartialTrades[i].ticket))
         {
            isPendingOrder = true;
            Print("🔄 Trade principal ", sellPartialTrades[i].ticket, " encore en attente d'exécution");
         }
         else
         {
            bool foundNewPosition = false;
            for(int j = 0; j < PositionsTotal(); j++)
            {
               ulong posTicket = PositionGetTicket(j);
               if(PositionSelectByTicket(posTicket))
               {
                  if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                     PositionGetString(POSITION_SYMBOL) == _Symbol &&
                     (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
                     MathAbs(PositionGetDouble(POSITION_VOLUME) - sellPartialTrades[i].initialVolume) < 0.001 &&
                     MathAbs(PositionGetDouble(POSITION_PRICE_OPEN) - sellPartialTrades[i].openPrice) < 0.001)
                  {
                     Print("🔄 Trade principal trouvé avec nouveau ticket: ", posTicket, " (ancien: ", sellPartialTrades[i].ticket, ")");
                     sellPartialTrades[i].ticket = posTicket;
                     foundNewPosition = true;
                     mainTradeExists = true;
                     break;
                  }
               }
            }
            
            if(!foundNewPosition)
            {
               Print("⚠️ Trade principal ", sellPartialTrades[i].ticket, " n'existe plus - nettoyage du système partiel");
               for(int j = PositionsTotal()-1; j >= 0; j--)
               {
                  ulong helperTicket = PositionGetTicket(j);
                  if(PositionSelectByTicket(helperTicket))
                  {
                     if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                        PositionGetString(POSITION_SYMBOL) == _Symbol &&
                        (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                     {
                        double helperVolume = PositionGetDouble(POSITION_VOLUME);
                        if(MathAbs(helperVolume - sellPartialTrades[i].unitSize) < 0.001)
                        {
                           Print("🧹 Fermeture helper orphelin: ", helperTicket, " (", helperVolume, " lots)");
                           trade.PositionClose(helperTicket);
                        }
                     }
                  }
               }
               
               Print("🏁 Cycle SELL ", sellPartialTrades[i].ticket, " nettoyé - système supprimé");
               ArrayRemove(sellPartialTrades, i, 1);
               continue;
            }
         }
      }
      
      if(isPendingOrder)
      {
         continue;
      }
      
      if(CheckMainTradeTP(sellPartialTrades[i], POSITION_TYPE_SELL))
      {
         Print("🎯 Trade principal ", sellPartialTrades[i].ticket, " atteint TP complet - fin de cycle");
         ArrayRemove(sellPartialTrades, i, 1);
         continue;
      }
      PlaceHelperTrade(sellPartialTrades[i], POSITION_TYPE_SELL);
      if(CheckCombinedTP(sellPartialTrades[i], POSITION_TYPE_SELL))
      {
         Print("🏁 Cycle SELL ", sellPartialTrades[i].ticket, " terminé après TP combiné");
         ArrayRemove(sellPartialTrades, i, 1);
         continue;
      }
   }
}

double CalculateGridVolume(bool isBuy, int gridLevel)
{
   double baseVolume = isBuy ? BaseVolumeBuy : BaseVolumeSell;
   double multiplier = isBuy ? GridMultiplierBuy : GridMultiplierSell;
   double maxVolume = isBuy ? MaxBaseVolumeBuy : MaxBaseVolumeSell;
   double gridVolume = baseVolume * MathPow(multiplier, gridLevel);
   if(maxVolume > 0 && gridVolume > maxVolume)
      gridVolume = maxVolume;
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   gridVolume = MathCeil(gridVolume / volStep) * volStep;
   gridVolume = NormalizeDouble(gridVolume, 2);
   return gridVolume;
}

double CalculateOptimalUnitSize(double totalVolume)
{
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(volStep >= 1.0)        // Actions secondaires (step = 1.0)
   {
      if(totalVolume >= 10.0) return 1.0;      
      else return MathMax(1.0, totalVolume / 10);
   }
   else if(volStep >= 0.1)   // Actions principales (step = 0.1)
   {
      if(totalVolume >= 1.0)  return 0.1;      
      else if(totalVolume >= 0.5) return 0.05; 
      else return MathMax(0.1, totalVolume / 10);
   }
   else                      // Forex (step = 0.01)
   {
      if(totalVolume >= 1.0)  return 0.1;      
      else if(totalVolume >= 0.5) return 0.05; 
      else if(totalVolume >= 0.2) return 0.02; 
      else if(totalVolume >= 0.1) return 0.01; 
      else return MathMax(0.01, totalVolume / 10);
   }
}

double CalculateTradeVolume(bool isBuy, int gridLevel)
{
   bool useGrid = isBuy ? UseGridVolumeBuy : UseGridVolumeSell;
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minVolume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(!useGrid)
   {
      double fixedLot = isBuy ? LotSizeBuy : LotSizeSell;
      if(fixedLot < minVolume)
         fixedLot = minVolume;
      fixedLot = MathRound(fixedLot / volStep) * volStep;
      fixedLot = NormalizeDouble(fixedLot, 2);
      return fixedLot;
   }
   else
   {
      double baseVolume = isBuy ? BaseVolumeBuy : BaseVolumeSell;
      double multiplier = isBuy ? GridMultiplierBuy : GridMultiplierSell;
      double maxVolume = isBuy ? MaxBaseVolumeBuy : MaxBaseVolumeSell;
      double gridVolume = baseVolume * MathPow(multiplier, gridLevel);
      if(maxVolume > 0 && gridVolume > maxVolume)
         gridVolume = maxVolume;
      if(gridVolume < minVolume)
      {
         gridVolume = minVolume;
         Print("📉 Trade ", gridLevel + 1, " (", (isBuy ? "BUY" : "SELL"), 
               "): Volume calculé sous le minimum → Forcé à ", minVolume, " lots");
      }
      if(gridVolume > minVolume)
      {
         gridVolume = MathCeil(gridVolume / volStep) * volStep;
      }
      else
      {
         gridVolume = MathRound(gridVolume / volStep) * volStep;
      }
      gridVolume = NormalizeDouble(gridVolume, 2);
      return gridVolume;
   }
}

double GetBaseVolumeForCalculations(bool isBuy)
{
   bool useGrid = isBuy ? UseGridVolumeBuy : UseGridVolumeSell;
   if(!useGrid)
   {
      return isBuy ? LotSizeBuy : LotSizeSell;
   }
   else
   {
      return isBuy ? BaseVolumeBuy : BaseVolumeSell;
   }
}

bool IsPriceWithinBuyLimits(double price)
{
   if(PrixMinimumAchat > 0.0 && price < PrixMinimumAchat)
      return false;
   if(PrixMaximumAchat > 0.0 && price > PrixMaximumAchat)
      return false;
   return true;
}

bool IsPriceWithinSellLimits(double price)
{
   if(PrixMinimumVente > 0.0 && price < PrixMinimumVente)
      return false;
   if(PrixMaximumVente > 0.0 && price > PrixMaximumVente)
      return false;
   return true;
}

//+------------------------------------------------------------------+
//| Validation complète avant tout placement d'ordre                |
//+------------------------------------------------------------------+
bool CanPlaceTradeWithFullValidation(ENUM_POSITION_TYPE type, double proposedPrice = 0.0)
{
   // 1. CRITIQUE: Vérifier le budget disponible
   if(!CanAffordNextTrade(type == POSITION_TYPE_BUY))
   {
      Print("❌ Trade bloqué: Budget insuffisant pour ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"));
      return false;
   }
   
   // 2. Vérifier les limites de nombre de trades
   int currentTrades = CountPositions(type);
   int maxTrades = (type == POSITION_TYPE_BUY) ? MaxBuyTrades : MaxSellTrades;
   if(currentTrades >= maxTrades)
   {
      Print("❌ Trade bloqué: Limite de trades atteinte (", currentTrades, "/", maxTrades, ") pour ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"));
      return false;
   }
   
   // 3. Vérifier les conditions temporelles (timeframe et horaires)
   ENUM_TIMEFRAMES timeframe = (type == POSITION_TYPE_BUY) ? TimeframeBuy : TimeframeSell;
   if(!IsValidTradingTime(timeframe, type == POSITION_TYPE_BUY))
   {
      Print("❌ Trade bloqué: Horaire de trading non valide pour ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"));
      return false;
   }
   
   // 4. Vérifier les limites de prix si un prix est proposé
   if(proposedPrice > 0.0)
   {
      if(type == POSITION_TYPE_BUY && !IsPriceWithinBuyLimits(proposedPrice))
      {
         Print("❌ Trade BUY bloqué: Prix (", DoubleToString(proposedPrice, _Digits), 
               ") hors limites [", DoubleToString(PrixMinimumAchat, _Digits), " - ", 
               DoubleToString(PrixMaximumAchat, _Digits), "]");
         return false;
      }
      if(type == POSITION_TYPE_SELL && !IsPriceWithinSellLimits(proposedPrice))
      {
         Print("❌ Trade SELL bloqué: Prix (", DoubleToString(proposedPrice, _Digits), 
               ") hors limites [", DoubleToString(PrixMinimumVente, _Digits), " - ", 
               DoubleToString(PrixMaximumVente, _Digits), "]");
         return false;
      }
   }
   
   // 5. Vérifier la distance minimum entre trades (sauf pour les modes spéciaux)
   bool isPartialClosureMode = (type == POSITION_TYPE_BUY && BuyMode == BUY_PARTIAL_CLOSURE) ||
                               (type == POSITION_TYPE_SELL && SellMode == SELL_PARTIAL_CLOSURE);
   if(!isPartialClosureMode && proposedPrice > 0.0)
   {
      int minDistance = (type == POSITION_TYPE_BUY) ? DistanceMinEntre2TradesBuy : DistanceMinEntre2TradesSell;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol &&
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double distance = MathAbs(proposedPrice - openPrice) / _Point;
               if(distance < minDistance)
               {
                  Print("❌ Trade bloqué: Distance insuffisante (", distance, " < ", minDistance, " points) pour ", (type == POSITION_TYPE_BUY ? "BUY" : "SELL"));
                  return false;
               }
            }
         }
      }
   }
   
   return true;
}

//+======================================+
//+======================================+

bool effectiveEnableGraphics;
string g_Symbols[];
string Line1Text    = "Technic' informatique";
string Line1Font    = "Comic Sans MS";
int    Line1XOffset = 60;
int    Line1YOffset = 5;
string Line2Text    = "Panneau de contrôle";
string Line2Font    = "Comic Sans MS";
int    Line2XOffset = 10;
int    Line2YOffset = 45;
string Line7Text    = "Spread actuel :";
string Line7Font    = "Comic Sans MS";
int    Line7XOffset = 10;
int    Line7YOffset = 70;
string Line3Text    = "Nombre d'achats :";
string Line3Font    = "Comic Sans MS";
int    Line3XOffset = 10;
int    Line3YOffset = 105;
string Line3_1Text    = "Ajout/Modif. ordre d'achat dans : ";
string Line3_1Font    = "Comic Sans MS";
int    Line3_1XOffset = 10;
int    Line3_1YOffset = 130;
string Line6Text    = "Solde nul à la baisse :";
string Line6Font    = "Comic Sans MS";
int    Line6XOffset = 10;
int    Line6YOffset = 155;
string Line4Text    = "Nombre de ventes :";
string Line4Font    = "Comic Sans MS";
int    Line4XOffset = 10;
int    Line4YOffset = 190;
string Line4_1Text    = "Ajout/Modif. ordre de vente dans : ";
string Line4_1Font    = "Comic Sans MS";
int    Line4_1XOffset = 10;
int    Line4_1YOffset = 215;
string Line5Text    = "Solde nul à la hausse :";
string Line5Font    = "Comic Sans MS";
int    Line5XOffset = 10;
int    Line5YOffset = 240;
string Line8Text    = "Gains/Pertes (mois dernier) :";
string Line8Font    = "Comic Sans MS";
int    Line8Size    = 14;
color  Line8Color   = clrWhite;
int    Line8XOffset = 10;
int    Line8YOffset = 275;
string Line9Text    = "Gains/Pertes (mois en cours) :";
string Line9Font    = "Comic Sans MS";
int    Line9Size    = 14;
color  Line9Color   = clrWhite;
int    Line9XOffset = 10;
int    Line9YOffset = 300;
string Line10Text   = "Gains/Pertes (14j) :";
string Line10Font   = "Comic Sans MS";
int    Line10Size   = 14;
color  Line10Color  = clrWhite;
int    Line10XOffset = 10;
int    Line10YOffset = 325;
string Line11Text   = "Gains/Pertes (7j) :";
string Line11Font   = "Comic Sans MS";
int    Line11Size   = 14;
color  Line11Color  = clrWhite;
int    Line11XOffset = 10;
int    Line11YOffset = 350;
string Line12Text   = "Gains/Pertes (hier) :";
string Line12Font   = "Comic Sans MS";
int    Line12Size   = 14;
color  Line12Color  = clrWhite;
int    Line12XOffset = 10;
int    Line12YOffset = 375;
string Line13Text   = "Gains/Pertes (jour) :";
string Line13Font   = "Comic Sans MS";
int    Line13Size   = 14;
color  Line13Color  = clrWhite;
int    Line13XOffset = 10;
int    Line13YOffset = 400;
string Line14Text   = "Gains/Pertes actuel :";
string Line14Font   = "Comic Sans MS";
int    Line14Size   = 14;
color  Line14Color  = clrWhite;
int    Line14XOffset = 10;
int    Line14YOffset = 425;
string ExtractSymbol(string combined)
  {
   int len = StringLen(combined);
   if(len < LongeurMagic)
      return combined;
   bool isDigits = true;
   for(int i = len - LongeurMagic; i < len; i++)
     {
      string ch = StringSubstr(combined, i, 1);
      if(ch < "0" || ch > "9")
        {
         isDigits = false;
         break;
        }
     }
   if(isDigits)
      return StringSubstr(combined, 0, len - LongeurMagic);
   else
      return combined;
  }

long ExtractMagic(string combined)
  {
   int len = StringLen(combined);
   if(len < LongeurMagic)
      return 0;
   bool isDigits = true;
   for(int i = len - LongeurMagic; i < len; i++)
     {
      string ch = StringSubstr(combined, i, 1);
      if(ch < "0" || ch > "9")
        {
         isDigits = false;
         break;
        }
     }
   if(isDigits)
      return StringToInteger(StringSubstr(combined, len - LongeurMagic));
   else
      return 0;
  }

color GetProfitColor(double profit)
  {
   if(profit > 0)
      return clrLimeGreen;
   else
      if(profit < 0)
         return clrCrimson;
   return clrWhite;
  }

double CalculateProfitSymbol(string symbol, long magicNumber, datetime startTime, datetime endTime)
  {
   double totalProfit = 0;
   if(!HistorySelect(startTime, endTime))
     {
      return 0;
     }
   int totalDeals = HistoryDealsTotal();
   for(int i = 0; i < totalDeals; i++)
     {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket <= 0)
         continue;
      if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT)
         continue;
      string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
      double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
      long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      ulong dealPositionId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
      if(dealSymbol == symbol &&
         dealTime >= startTime &&
         dealTime < endTime &&
         (dealMagic == magicNumber || (magicNumber != 0 && dealMagic == 0)))
        {
         totalProfit += dealProfit;
         totalProfit += HistoryDealGetDouble(dealTicket, DEAL_SWAP);
         totalProfit += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
        }
     }
   return totalProfit;
  }

double CalculateFloatingProfitSymbol(string symbol, long magic)
  {
   double floatingProfit = 0.0;
   double totalCosts = 0.0;
   int totalPositions = PositionsTotal();
   for(int i = 0; i < totalPositions; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), symbol) == 0)
           {
            if(magic > 0)
              {
               if(PositionGetInteger(POSITION_MAGIC) != magic)
                  continue;
              }
            floatingProfit += PositionGetDouble(POSITION_PROFIT);
            totalCosts += PositionGetDouble(POSITION_SWAP);
            ulong positionId = PositionGetInteger(POSITION_IDENTIFIER);
            if(HistorySelectByPosition(positionId))
              {
               int deals = HistoryDealsTotal();
               for(int j = 0; j < deals; j++)
                 {
                  ulong dealTicket = HistoryDealGetTicket(j);
                  if(dealTicket > 0)
                    {
                     totalCosts += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
                    }
                 }
              }
           }
        }
     }
   return floatingProfit + totalCosts;
  }

double CalculateBreakEvenLongSymbol(string symbol)
  {
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double floatingProfitLoss = AccountInfoDouble(ACCOUNT_PROFIT);
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double totalVolumeBuy = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), symbol) == 0 &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            totalVolumeBuy += PositionGetDouble(POSITION_VOLUME);
           }
        }
     }
   double equity = accountBalance + floatingProfitLoss;
   double breakEvenPrice = 0.0;
   if(totalVolumeBuy > 0)
     {
      breakEvenPrice = currentPrice - (equity / (contractSize * totalVolumeBuy));
     }
   else
     {
      breakEvenPrice = currentPrice;
     }
   return breakEvenPrice;
  }

double CalculateBreakEvenShortSymbol(string symbol)
  {
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double floatingProfitLoss = AccountInfoDouble(ACCOUNT_PROFIT);
   double currentPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
   double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   double totalVolumeSell = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), symbol) == 0 &&
            (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            totalVolumeSell += PositionGetDouble(POSITION_VOLUME);
           }
        }
     }
   double equity = accountBalance + floatingProfitLoss;
   double breakEvenPrice = 0.0;
   if(totalVolumeSell > 0)
     {
      breakEvenPrice = currentPrice + (equity / (contractSize * totalVolumeSell));
     }
   else
     {
      breakEvenPrice = currentPrice;
     }
   return breakEvenPrice;
  }

void GetDynamicPanelPositionForPanel(int index, int &posX, int &posY)
  {
   posX = OffsetX + index * (((int)(PanelWidth * Ratio)) + 5);
   posY = OffsetY;
  }

void UpdateTextLineEx(const string name,
                      const string text,
                      const string font,
                      const int    size,
                      const color  col,
                      const int    baseX,
                      const int    baseY,
                      const int    offsetX,
                      const int    offsetY)
  {
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, (int)(size * Ratio));
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, baseX + (int)(offsetX * Ratio));
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, baseY + (int)(offsetY * Ratio));
  }

string FormatTimeLeft(int seconds, ENUM_TIMEFRAMES timeframe, int startHour, int startMinute)
  {
   datetime currentTime = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(currentTime, dt);
   int periodMinutes;
   switch(timeframe)
     {
      case PERIOD_M1:  periodMinutes = 1;   break;
      case PERIOD_M2:  periodMinutes = 2;   break;
      case PERIOD_M3:  periodMinutes = 3;   break;
      case PERIOD_M4:  periodMinutes = 4;   break;
      case PERIOD_M5:  periodMinutes = 5;   break;
      case PERIOD_M6:  periodMinutes = 6;   break;
      case PERIOD_M10: periodMinutes = 10;  break;
      case PERIOD_M12: periodMinutes = 12;  break;
      case PERIOD_M15: periodMinutes = 15;  break;
      case PERIOD_M20: periodMinutes = 20;  break;
      case PERIOD_M30: periodMinutes = 30;  break;
      case PERIOD_H1:  periodMinutes = 60;  break;
      case PERIOD_H2:  periodMinutes = 120; break;
      case PERIOD_H3:  periodMinutes = 180; break;
      case PERIOD_H4:  periodMinutes = 240; break;
      case PERIOD_H6:  periodMinutes = 360; break;
      case PERIOD_H8:  periodMinutes = 480; break;
      case PERIOD_H12: periodMinutes = 720; break;
      case PERIOD_D1:  periodMinutes = 1440;break;
      case PERIOD_W1:  periodMinutes = 10080; break;
      case PERIOD_MN1: periodMinutes = 43200; break;
      default:
         periodMinutes = PeriodSeconds(timeframe)/60;
         break;
     }
   int currentMinutes = (dt.hour * 60) + dt.min;
   int startMinutes = (startHour * 60) + startMinute;
   int minutesSinceSync;
   if(currentMinutes >= startMinutes)
     {
      minutesSinceSync = (currentMinutes - startMinutes) % periodMinutes;
     }
   else
     {
      int minutesToMidnight = 1440 - startMinutes;
      minutesSinceSync = (minutesToMidnight + currentMinutes) % periodMinutes;
     }
   int secondsLeft = ((periodMinutes - minutesSinceSync) * 60) - dt.sec;
   if(secondsLeft <= 0)
     {
      secondsLeft = periodMinutes * 60;
     }
   int hours = (secondsLeft / 3600) % 24;
   int mins = (secondsLeft % 3600) / 60;
   int secs = secondsLeft % 60;
   return StringFormat("%02d:%02d:%02d", hours, mins, secs);
  }

void UpdatePanelForSymbol(string symWithMagic, int index)
  {
   int posX, posY;
   GetDynamicPanelPositionForPanel(index, posX, posY);
   string actualSymbol = ExtractSymbol(symWithMagic);
   long magicNumber    = ExtractMagic(symWithMagic);
   string panelName = "ControlPanel_" + IntegerToString(index);
   ObjectSetInteger(0, panelName, OBJPROP_XDISTANCE, posX);
   ObjectSetInteger(0, panelName, OBJPROP_YDISTANCE, posY);
   ObjectSetInteger(0, panelName, OBJPROP_XSIZE, (int)(PanelWidth * Ratio));
   ObjectSetInteger(0, panelName, OBJPROP_YSIZE, (int)(PanelHeight * Ratio));
   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime todayStart = StructToTime(dt);
   datetime monthStart = StringToTime(StringFormat("%04d.%02d.01 00:00:00", dt.year, dt.mon));
   datetime lastMonthStart = monthStart - 30 * 86400;
   double profit_last_month = CalculateProfitSymbol(actualSymbol, magicNumber, lastMonthStart, monthStart);
   double profit_this_month = CalculateProfitSymbol(actualSymbol, magicNumber, monthStart, now);
   double profit_14j = CalculateProfitSymbol(actualSymbol, magicNumber, now - 14 * 86400, now);
   double profit_7j = CalculateProfitSymbol(actualSymbol, magicNumber, now - 7 * 86400, now);
   double profit_hier = CalculateProfitSymbol(actualSymbol, magicNumber, todayStart - 86400, todayStart - 1);
   double profit_jour = CalculateProfitSymbol(actualSymbol, magicNumber, todayStart, now);
   double profit_float = CalculateFloatingProfitSymbol(actualSymbol, magicNumber);
   double ask = SymbolInfoDouble(actualSymbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(actualSymbol, SYMBOL_BID);
   double point = SymbolInfoDouble(actualSymbol, SYMBOL_POINT);
   double spreadPoints = (BackTestMode) ? BackTestSpread : ((ask != 0 && bid != 0) ? (ask - bid) / point : 0.0);
   double breakEvenShort = CalculateBreakEvenShortSymbol(actualSymbol);
   double breakEvenLong = CalculateBreakEvenLongSymbol(actualSymbol);
   bool hasShort = false, hasLong = false;
   int totalPositions = PositionsTotal();
   int openBuyCount = 0, openSellCount = 0;
   for(int iPos = 0; iPos < totalPositions; iPos++)
     {
      ulong ticket = PositionGetTicket(iPos);
      if(PositionSelectByTicket(ticket))
        {
         if(StringCompare(PositionGetString(POSITION_SYMBOL), actualSymbol) == 0 &&
            (magicNumber == 0 || PositionGetInteger(POSITION_MAGIC) == magicNumber))
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               hasShort = true;
               openSellCount++;
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               hasLong = true;
               openBuyCount++;
              }
           }
        }
     }
   string timeLeftBuy = FormatTimeLeft(0, TimeframeBuy, StartHourBuy, StartMinuteBuy);
   string timeLeftSell = FormatTimeLeft(0, TimeframeSell, StartHourSell, StartMinuteSell);
   MqlDateTime brokerTime;
   TimeToStruct(TimeCurrent(), brokerTime);
   string brokerTimeStr = StringFormat("%02d:%02d:%02d", brokerTime.hour, brokerTime.min, brokerTime.sec);
   string fixedLine2 = "Actif : " + actualSymbol + " - N° magique : " + IntegerToString(magicNumber);
   UpdateTextLineEx("TextLine1_" + IntegerToString(index), Line1Text, Line1Font, Line1Size, Line1Color, posX, posY, Line1XOffset, Line1YOffset);
   UpdateTextLineEx("TextLine2_" + IntegerToString(index), fixedLine2, Line2Font, Line2Size, Line2Color, posX, posY, Line2XOffset, Line2YOffset);
   UpdateTextLineEx("TextLine3_" + IntegerToString(index),
                    openBuyCount == 0 ? Line3Text : Line3Text + " " + IntegerToString(openBuyCount),
                    Line3Font, Line3Size, Line3Color, posX, posY, Line3XOffset, Line3YOffset);
   UpdateTextLineEx("TextLine3_1_" + IntegerToString(index),
                    Line3_1Text + timeLeftBuy,
                    Line3_1Font, Line3_1Size, Line3_1Color, posX, posY, Line3_1XOffset, Line3_1YOffset);
   UpdateTextLineEx("TextLine6_" + IntegerToString(index),
                    hasLong ? Line6Text + " " + DoubleToString(breakEvenLong, _Digits) : Line6Text,
                    Line6Font, Line6Size, Line6Color, posX, posY, Line6XOffset, Line6YOffset);
   UpdateTextLineEx("TextLine4_" + IntegerToString(index),
                    openSellCount == 0 ? Line4Text : Line4Text + " " + IntegerToString(openSellCount),
                    Line4Font, Line4Size, Line4Color, posX, posY, Line4XOffset, Line4YOffset);
   UpdateTextLineEx("TextLine4_1_" + IntegerToString(index),
                    Line4_1Text + timeLeftSell,
                    Line4_1Font, Line4_1Size, Line4_1Color, posX, posY, Line4_1XOffset, Line4_1YOffset);
   UpdateTextLineEx("TextLine5_" + IntegerToString(index),
                    hasShort ? Line5Text + " " + DoubleToString(breakEvenShort, _Digits) : Line5Text,
                    Line5Font, Line5Size, Line5Color, posX, posY, Line5XOffset, Line5YOffset);
   UpdateTextLineEx("TextLine7_" + IntegerToString(index),
                    "Heure : " + brokerTimeStr + " - Spread : " + DoubleToString(spreadPoints, 0),
                    Line7Font, Line7Size, Line7Color, posX, posY, Line7XOffset, Line7YOffset);
   UpdateTextLineEx("TextLine8_" + IntegerToString(index),
                    Line8Text + " " + DoubleToString(profit_last_month, 2) + " €",
                    Line8Font, Line8Size, profit_last_month > 0 ? clrForestGreen : (profit_last_month < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line8XOffset, Line8YOffset);
   UpdateTextLineEx("TextLine9_" + IntegerToString(index),
                    Line9Text + " " + DoubleToString(profit_this_month, 2) + " €",
                    Line9Font, Line9Size, profit_this_month > 0 ? clrForestGreen : (profit_this_month < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line9XOffset, Line9YOffset);
   UpdateTextLineEx("TextLine10_" + IntegerToString(index),
                    Line10Text + " " + DoubleToString(profit_14j, 2) + " €",
                    Line10Font, Line10Size, profit_14j > 0 ? clrForestGreen : (profit_14j < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line10XOffset, Line10YOffset);
   UpdateTextLineEx("TextLine11_" + IntegerToString(index),
                    Line11Text + " " + DoubleToString(profit_7j, 2) + " €",
                    Line11Font, Line11Size, profit_7j > 0 ? clrForestGreen : (profit_7j < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line11XOffset, Line11YOffset);
   UpdateTextLineEx("TextLine12_" + IntegerToString(index),
                    Line12Text + " " + DoubleToString(profit_hier, 2) + " €",
                    Line12Font, Line12Size, profit_hier > 0 ? clrForestGreen : (profit_hier < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line12XOffset, Line12YOffset);
   UpdateTextLineEx("TextLine13_" + IntegerToString(index),
                    Line13Text + " " + DoubleToString(profit_jour, 2) + " €",
                    Line13Font, Line13Size, profit_jour > 0 ? clrForestGreen : (profit_jour < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line13XOffset, Line13YOffset);
   UpdateTextLineEx("TextLine14_" + IntegerToString(index),
                    Line14Text + " " + DoubleToString(profit_float, 2) + " €",
                    Line14Font, Line14Size, profit_float > 0 ? clrForestGreen : (profit_float < 0 ? clrCrimson : clrWhite),
                    posX, posY, Line14XOffset, Line14YOffset);
   ObjectSetInteger(0, "TextLine1_" + IntegerToString(index), OBJPROP_ALIGN, ALIGN_CENTER);
   ObjectSetInteger(0, "TextLine2_" + IntegerToString(index), OBJPROP_ALIGN, ALIGN_CENTER);
   string upLineName = "ZeroBalanceUpLine_" + IntegerToString(index);
   string downLineName = "ZeroBalanceDownLine_" + IntegerToString(index);
   if(openSellCount > 0)
     {
      if(ObjectFind(0, upLineName) == -1)
        {
         ObjectCreate(0, upLineName, OBJ_HLINE, 0, 0, 0);
         ObjectSetInteger(0, upLineName, OBJPROP_COLOR, Line5Color);
         ObjectSetInteger(0, upLineName, OBJPROP_BACK, true);
        }
      ObjectSetDouble(0, upLineName, OBJPROP_PRICE, breakEvenShort);
     }
   else
     {
      if(ObjectFind(0, upLineName) != -1)
         ObjectDelete(0, upLineName);
     }
   if(openBuyCount > 0)
     {
      if(ObjectFind(0, downLineName) == -1)
        {
         ObjectCreate(0, downLineName, OBJ_HLINE, 0, 0, 0);
         ObjectSetInteger(0, downLineName, OBJPROP_COLOR, Line6Color);
         ObjectSetInteger(0, downLineName, OBJPROP_BACK, true);
        }
      ObjectSetDouble(0, downLineName, OBJPROP_PRICE, breakEvenLong);
     }
   else
     {
      if(ObjectFind(0, downLineName) != -1)
         ObjectDelete(0, downLineName);
     }
  }

void DrawVirtualTP()
{
   if(BuyMode != BUY_MODE_NONE && CountPositions(POSITION_TYPE_BUY) > 0)
   {
      double virtualTP_BUY = 0.0;
      double currentPrice = GetAdjustedBid();
      double point = _Point;
      if(BuyMode == BUY_CUMUL_SINGLE || BuyMode == BUY_CLOSE_CANDLE)
      {
         double totalVolume = 0.0;
         double sumWeighted = 0.0;
         for(int i = 0; i < PositionsTotal(); i++)
         {
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
               if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
                  PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               {
                  double vol = PositionGetDouble(POSITION_VOLUME);
                  totalVolume += vol;
                  sumWeighted += vol * PositionGetDouble(POSITION_PRICE_OPEN);
               }
            }
         }
         if(totalVolume > 0)
         {
            double weightedAvg = sumWeighted / totalVolume;
            double targetPips = InitialTakeProfitBuy;
            double totalPipsNeeded = targetPips;
            double currentTotalPips = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
            double remainingPips = totalPipsNeeded - currentTotalPips;
            virtualTP_BUY = currentPrice + (remainingPips * point);
         }
      }
      else if(BuyMode == BUY_CUMUL_MULTI)
      {
         double totalVolume = GetTotalVolume(POSITION_TYPE_BUY);
         if(totalVolume > 0)
         {
            double volumeMultiplier = totalVolume / LotSizeBuy;
            double targetPips = InitialTakeProfitBuy * volumeMultiplier;
            double currentTotalPips = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
            double remainingPips = targetPips - currentTotalPips;
            virtualTP_BUY = currentPrice + (remainingPips * point);
         }
      }
      else if(BuyMode == BUY_CUMUL_POS)
      {
         int nbTradesBuy = CountPositions(POSITION_TYPE_BUY);
         if(nbTradesBuy > 0)
         {
            double reductionFactor = CumulPosReductionFactorBuy;
            double minTPPercent = CumulPosMinTPPercentBuy;
            double tpReductionPercent = 1.0 - (reductionFactor * (nbTradesBuy - 1));
            tpReductionPercent = MathMax(tpReductionPercent, minTPPercent);
            double tpPerPosition = InitialTakeProfitBuy * tpReductionPercent;
            double targetPips = tpPerPosition * nbTradesBuy;
            double currentTotalPips = CalculateTotalPipsWithCosts(POSITION_TYPE_BUY);
            double remainingPips = targetPips - currentTotalPips;
            virtualTP_BUY = currentPrice + (remainingPips * point);
         }
      }
      if(virtualTP_BUY > 0)
      {
         if(ObjectFind(0, "VirtualTP_BUY") < 0)
         {
            ObjectCreate(0, "VirtualTP_BUY", OBJ_HLINE, 0, 0, virtualTP_BUY);
         }
         else
         {
            ObjectSetDouble(0, "VirtualTP_BUY", OBJPROP_PRICE, virtualTP_BUY);
         }
         ObjectSetInteger(0, "VirtualTP_BUY", OBJPROP_COLOR, clrLimeGreen);
         ObjectSetInteger(0, "VirtualTP_BUY", OBJPROP_WIDTH, 3);
         ObjectSetInteger(0, "VirtualTP_BUY", OBJPROP_BACK, true);
         ObjectSetString(0, "VirtualTP_BUY", OBJPROP_TEXT, 
                        "TP BUY (" + EnumToString(BuyMode) + "): " + DoubleToString(virtualTP_BUY, _Digits));
      }
   }
   else
   {
      if(ObjectFind(0, "VirtualTP_BUY") >= 0)
         ObjectDelete(0, "VirtualTP_BUY");
   }
   if(SellMode != SELL_MODE_NONE && CountPositions(POSITION_TYPE_SELL) > 0)
   {
      double virtualTP_SELL = 0.0;
      double currentPrice = GetAdjustedAsk();
      double point = _Point;
      if(SellMode == SELL_CUMUL_SINGLE || SellMode == SELL_CLOSE_CANDLE)
      {
         double targetPips = InitialTakeProfitSell;
         double currentTotalPips = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
         double remainingPips = targetPips - currentTotalPips;
         virtualTP_SELL = currentPrice - (remainingPips * point);
      }
      else if(SellMode == SELL_CUMUL_MULTI)
      {
         double totalVolume = GetTotalVolume(POSITION_TYPE_SELL);
         if(totalVolume > 0)
         {
            double volumeMultiplier = totalVolume / LotSizeSell;
            double targetPips = InitialTakeProfitSell * volumeMultiplier;
            double currentTotalPips = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
            double remainingPips = targetPips - currentTotalPips;
            virtualTP_SELL = currentPrice - (remainingPips * point);
         }
      }
      else if(SellMode == SELL_CUMUL_POS)
      {
         int nbTradesSell = CountPositions(POSITION_TYPE_SELL);
         if(nbTradesSell > 0)
         {
            double reductionFactor = CumulPosReductionFactorSell;
            double minTPPercent = CumulPosMinTPPercentSell;
            double tpReductionPercent = 1.0 - (reductionFactor * (nbTradesSell - 1));
            tpReductionPercent = MathMax(tpReductionPercent, minTPPercent);
            double tpPerPosition = InitialTakeProfitSell * tpReductionPercent;
            double targetPips = tpPerPosition * nbTradesSell;
            double currentTotalPips = CalculateTotalPipsWithCosts(POSITION_TYPE_SELL);
            double remainingPips = targetPips - currentTotalPips;
            virtualTP_SELL = currentPrice - (remainingPips * point);
         }
      }
      if(virtualTP_SELL > 0)
      {
         if(ObjectFind(0, "VirtualTP_SELL") < 0)
         {
            ObjectCreate(0, "VirtualTP_SELL", OBJ_HLINE, 0, 0, virtualTP_SELL);
         }
         else
         {
            ObjectSetDouble(0, "VirtualTP_SELL", OBJPROP_PRICE, virtualTP_SELL);
         }
         ObjectSetInteger(0, "VirtualTP_SELL", OBJPROP_COLOR, clrCrimson);
         ObjectSetInteger(0, "VirtualTP_SELL", OBJPROP_WIDTH, 3);
         ObjectSetInteger(0, "VirtualTP_SELL", OBJPROP_BACK, true);
         ObjectSetString(0, "VirtualTP_SELL", OBJPROP_TEXT, 
                        "TP SELL (" + EnumToString(SellMode) + "): " + DoubleToString(virtualTP_SELL, _Digits));
      }
   }
   else
   {
      if(ObjectFind(0, "VirtualTP_SELL") >= 0)
         ObjectDelete(0, "VirtualTP_SELL");
   }
}

void InitializeGraphics()
  {
   if(!effectiveEnableGraphics) return;
   for(int i = 0; i < DisplayCount; i++)
     {
      string panelName = "ControlPanel_" + IntegerToString(i);
      if(!ObjectCreate(0, panelName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
        {
         continue;
        }
      ChartSetInteger(0, CHART_COLOR_BACKGROUND, 0, ChartBackgroundColor);
      ChartSetInteger(0, CHART_COLOR_GRID, 0, ChartGridColor);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, 0, CandleBullColor);
      ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, 0, CandleBearColor);
      ChartSetInteger(0, CHART_COLOR_CHART_UP, 0, CandleBullColor);
      ChartSetInteger(0, CHART_COLOR_CHART_DOWN, 0, CandleBearColor);
      ChartSetInteger(0, CHART_COLOR_FOREGROUND, 0, EnvironnementColor);
      ObjectSetInteger(0, panelName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, panelName, OBJPROP_XSIZE, PanelWidth);
      ObjectSetInteger(0, panelName, OBJPROP_YSIZE, PanelHeight);
      ObjectSetInteger(0, panelName, OBJPROP_BGCOLOR, PanelBackgroundColor);
      ObjectSetInteger(0, panelName, OBJPROP_COLOR, PanelBackgroundColor);
      ObjectSetString(0, panelName, OBJPROP_TEXT, "");
      ObjectSetInteger(0, panelName, OBJPROP_ZORDER, 0);
      string lineNames[] =
        {
         "TextLine1_", "TextLine2_", "TextLine3_", "TextLine3_1_", "TextLine6_",
         "TextLine4_", "TextLine4_1_", "TextLine5_", "TextLine7_",
         "TextLine8_", "TextLine9_", "TextLine10_", "TextLine11_",
         "TextLine12_", "TextLine13_", "TextLine14_"
        };
      for(int j = 0; j < ArraySize(lineNames); j++)
        {
         string objName = lineNames[j] + IntegerToString(i);
         if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0))
           {
           }
         ObjectSetInteger(0, objName, OBJPROP_ZORDER, 2);
        }
      string hLineUp = "ZeroBalanceUpLine_" + IntegerToString(i);
      string hLineDown = "ZeroBalanceDownLine_" + IntegerToString(i);
      if(!ObjectCreate(0, hLineUp, OBJ_HLINE, 0, 0, 0))
         if(!ObjectCreate(0, hLineDown, OBJ_HLINE, 0, 0, 0))
            ObjectSetInteger(0, hLineUp, OBJPROP_COLOR, Line5Color);
      ObjectSetInteger(0, hLineUp, OBJPROP_BACK, false);
      ObjectSetInteger(0, hLineUp, OBJPROP_ZORDER, 1);
      ObjectSetInteger(0, hLineDown, OBJPROP_COLOR, Line6Color);
      ObjectSetInteger(0, hLineDown, OBJPROP_BACK, false);
      ObjectSetInteger(0, hLineDown, OBJPROP_ZORDER, 1);
     }
   for(int i = 0; i < DisplayCount; i++)
     {
      string sym = (i < ArraySize(g_Symbols)) ? g_Symbols[i] : (_Symbol + "0");
      UpdatePanelForSymbol(sym, i);
     }
  }

void CleanupGraphics()
  {
   if(!effectiveEnableGraphics) return;
   string lineNames[] =
     {
      "TextLine1_", "TextLine2_", "TextLine3_", "TextLine3_1_", "TextLine6_",
      "TextLine4_", "TextLine4_1_", "TextLine5_", "TextLine7_",
      "TextLine8_", "TextLine9_", "TextLine10_", "TextLine11_",
      "TextLine12_", "TextLine13_", "TextLine14_"
     };
   for(int i = 0; i < DisplayCount; i++)
     {
      ObjectDelete(0, "ControlPanel_" + IntegerToString(i));
      for(int j = 0; j < ArraySize(lineNames); j++)
        {
         ObjectDelete(0, lineNames[j] + IntegerToString(i));
        }
      ObjectDelete(0, "ZeroBalanceUpLine_" + IntegerToString(i));
      ObjectDelete(0, "ZeroBalanceDownLine_" + IntegerToString(i));
     }
   ObjectDelete(0, "VirtualTP_BUY");
   ObjectDelete(0, "VirtualTP_SELL");
   ChartRedraw();
  }

void UpdateGraphics()
  {
   if(!effectiveEnableGraphics) return;
   for(int i = 0; i < DisplayCount; i++)
     {
      string sym = (i < ArraySize(g_Symbols)) ? g_Symbols[i] : (_Symbol + "0");
      UpdatePanelForSymbol(sym, i);
     }
   if(BuyMode != BUY_MODE_NONE || SellMode != SELL_MODE_NONE)
      DrawVirtualTP();
   ChartRedraw();
  }

//+======================================+
//+======================================+

int OnInit()
{
   effectiveEnableGraphics = EnableGraphics;
   if(!CheckLicense())
   {
      return(INIT_FAILED);
   }
   int symbolCount = StringSplit(DisplaySymbols, ',', g_Symbols);
   for(int i = symbolCount; i < DisplayCount; i++)
   {
      ArrayResize(g_Symbols, i + 1);
      g_Symbols[i] = _Symbol + "0";
   }
   InitializeGraphics();
   g_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   PrematureStop = false;
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
  {
   CleanupGraphics();
  }

void OnTick()
{
   if(BackTestMode)
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
      double currentDrawdown = balance - equity;
      if(currentDrawdown >= MathAbs(BackTestStopThreshold))
      {
         Print("⛔ Drawdown max atteint : ", currentDrawdown, "€ ≥ ", MathAbs(BackTestStopThreshold), "€");
         PrematureStop = true;
         TesterStop();
         return;
      }
   }

   bool isValidTimeBuy  = (MaxBuyTrades  > 0) ? IsValidTradingTime(TimeframeBuy, true)   : false;
   bool isValidTimeSell = (MaxSellTrades > 0) ? IsValidTradingTime(TimeframeSell, false) : false;
   if((MaxBuyTrades == 0 || !isValidTimeBuy) && (MaxSellTrades == 0 || !isValidTimeSell))
   {
      UpdateGraphics();
      ManagePendingOrders();
      SetInitialStopLoss();
      SetInitialTakeProfit();
      ManageTrailingStopLoss();
      CheckCumulativeSingleTP();
      CheckCumulativeMultiTP();
      CheckCumulativePosTP();
      CheckLadderProfitTP();
      CheckWaveRidingTP();
      CheckVixReversionTP();
      CheckMomentumBurstTP();
      CheckScalpAccumulatorTP();
      CheckVixOscillationMasterTP();
      CheckProfitCompoundingTP();
      CheckBreakoutSurferTP();
      ManagePartialClosureSystem();
      return;
   }

   UpdateGraphics();
   ManagePendingOrders();
   SetInitialStopLoss();
   SetInitialTakeProfit();
   ManageTrailingStopLoss();
   CheckCumulativeSingleTP();
   CheckCumulativeMultiTP();
   CheckCumulativePosTP();
   CheckLadderProfitTP();
   CheckWaveRidingTP();
   CheckVixReversionTP();
   CheckMomentumBurstTP();
   CheckScalpAccumulatorTP();
   CheckVixOscillationMasterTP();
   CheckProfitCompoundingTP();
   CheckBreakoutSurferTP();
   ManagePartialClosureSystem();
   static datetime lastCandleTimeBuy  = 0;
   static datetime lastCandleTimeSell = 0;
   datetime currentCandleTimeBuy  = (MaxBuyTrades  > 0) ? iTime(_Symbol, TimeframeBuy, 0)  : 0;
   datetime currentCandleTimeSell = (MaxSellTrades > 0) ? iTime(_Symbol, TimeframeSell, 0) : 0;
   bool newCandleBuy  = false;
   bool newCandleSell = false;
   if(MaxBuyTrades > 0 && currentCandleTimeBuy > lastCandleTimeBuy && isValidTimeBuy)
   {
      lastCandleTimeBuy = currentCandleTimeBuy;
      newCandleBuy = true;
      if(CountPositions(POSITION_TYPE_BUY) == 0)
      {
         if(!gridResetBuy)
         {
            for(int i = OrdersTotal() - 1; i >= 0; i--)
            {
               ulong ticket = OrderGetTicket(i);
               if(OrderSelect(ticket))
               {
                  if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
                     OrderGetString(ORDER_SYMBOL) == _Symbol)
                  {
                     ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
                     if(otype == ORDER_TYPE_BUY_STOP || otype == ORDER_TYPE_BUY_LIMIT)
                        trade.OrderDelete(ticket);
                  }
               }
            }
            gridResetBuy = true;
         }
      }
      else
         gridResetBuy = false;
      ENUM_ORDER_TYPE pendingTypeBuy = (!InverserOrdresBuy) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_BUY_LIMIT;
      bool canPlacePartialTrade = true;
      if(BuyMode == BUY_PARTIAL_CLOSURE && ArraySize(buyPartialTrades) > 0)
      {
         canPlacePartialTrade = false;
         Print("⚠️ BUY_PARTIAL_CLOSURE: Système partiel actif - nouveau trade principal bloqué");
      }
      else if(BuyMode == BUY_PARTIAL_CLOSURE)
      {
         Print("✅ BUY_PARTIAL_CLOSURE: Aucun système actif - nouveau trade principal autorisé");
      }

      if(CanPlaceAnotherBuy() &&
         CountPendingOrders(pendingTypeBuy) == 0 &&
         CountPositions(POSITION_TYPE_BUY) < MaxBuyTrades &&
         CanAffordNextTrade(true) &&  // Appel direct ici, seulement à la nouvelle bougie
         canPlacePartialTrade)
      {
         PlaceBuyOrder();
      }
   }

   if(MaxSellTrades > 0 && currentCandleTimeSell > lastCandleTimeSell && isValidTimeSell)
   {
      lastCandleTimeSell = currentCandleTimeSell;
      newCandleSell = true;
      if(CountPositions(POSITION_TYPE_SELL) == 0)
      {
         if(!gridResetSell)
         {
            for(int i = OrdersTotal() - 1; i >= 0; i--)
            {
               ulong ticket = OrderGetTicket(i);
               if(OrderSelect(ticket))
               {
                  if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
                     OrderGetString(ORDER_SYMBOL) == _Symbol)
                  {
                     ENUM_ORDER_TYPE otype = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
                     if(otype == ORDER_TYPE_SELL_STOP || otype == ORDER_TYPE_SELL_LIMIT)
                        trade.OrderDelete(ticket);
                  }
               }
            }
            gridResetSell = true;
         }
      }
      else
         gridResetSell = false;
      ENUM_ORDER_TYPE pendingTypeSell = (!InverserOrdresSell) ? ORDER_TYPE_SELL_STOP : ORDER_TYPE_SELL_LIMIT;
      bool canPlacePartialTrade = true;
      if(SellMode == SELL_PARTIAL_CLOSURE && ArraySize(sellPartialTrades) > 0)
      {
         canPlacePartialTrade = false;
         Print("⚠️ SELL_PARTIAL_CLOSURE: Système partiel actif - nouveau trade principal bloqué");
      }
      else if(SellMode == SELL_PARTIAL_CLOSURE)
      {
         Print("✅ SELL_PARTIAL_CLOSURE: Aucun système actif - nouveau trade principal autorisé");
      }

      if(CanPlaceAnotherSell() &&
         CountPendingOrders(pendingTypeSell) == 0 &&
         CountPositions(POSITION_TYPE_SELL) < MaxSellTrades &&
         CanAffordNextTrade(false) && // Appel direct ici, seulement à la nouvelle bougie
         canPlacePartialTrade)
      {
         PlaceSellOrder();
      }
   }

   if((newCandleBuy || newCandleSell) && 
      (BuyMode == BUY_CLOSE_CANDLE || SellMode == SELL_CLOSE_CANDLE))
   {
      Print("🕯️ Nouvelle bougie détectée - Vérification CLOSE_CANDLE");
      CheckCloseOnCandleIfProfit();
   }
}

double OnTester()
{
   if(PrematureStop)
      return 0;
   double netProfit = AccountInfoDouble(ACCOUNT_BALANCE) - g_initialBalance;
   if(MaxAccountBalance <= 0)
   {
      return netProfit;
   }
   
   return netProfit / MaxAccountBalance;
}